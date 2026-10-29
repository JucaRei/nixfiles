# lib/helpers.nix — construtores de hosts (NixOS, Home Manager standalone e ISO).
{ inputs, outputs, ... }:

let
  lib = inputs.nixpkgs.lib.extend (
    self: _super: {
      my = import ./options.nix { lib = self; };
    }
  );

  defaults = {
    username = "juca";
    platform = "x86_64-linux";
  };

  # Hosts com NVIDIA legacy (340). Vira o specialArg `isNvidia` dentro do HM integrado.
  # TODO: trocar por option de hardware lida via osConfig (como o dwm.nix já faz).
  nvidiaLegacyHosts = [ "rocinante" ];

  # Plataformas suportadas. Darwin fica de fora para acelerar `nix flake check`.
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  # Argumentos entregues a TODO módulo (NixOS e Home Manager).
  mkCommonArgs =
    {
      hostname,
      username,
      desktop,
      waylandShell,
      platform,
      stateVersion,
      isISO,
    }:
    {
      inherit
        inputs
        outputs
        hostname
        username
        desktop
        waylandShell
        platform
        stateVersion
        isISO
        ;
      isInstall = !isISO;
      isWorkstation = desktop != null;
      myLib = lib.my;
    };

  # nixgl.auto.nixGLDefault lê a NVIDIA do host (com --impure) e tenta construir um
  # nixGLNvidia que falha no nixpkgs 26.05. Com tipo explícito, fixa o default em
  # Intel/Mesa antes de qualquer módulo avaliá-lo.
  pinNixGLDefault = type: _final: prev: {
    nixgl = prev.nixgl // {
      auto = prev.nixgl.auto // {
        nixGLDefault = if type == "mesa" then prev.nixgl.nixGLMesa else prev.nixgl.nixGLIntel;
      };
    };
  };

  nixpkgsConfig = import ./nixpkgs-config.nix;

  # pkgs do Home Manager standalone (o nixpkgs.* do módulo HM não vale quando `pkgs` é passado).
  mkPkgs =
    { platform, nixGLType }:
    import inputs.nixpkgs {
      localSystem = platform;
      config = nixpkgsConfig;
      overlays = [
        inputs.nixgl.overlay
      ]
      ++ lib.optional (nixGLType != null && nixGLType != "auto") (pinNixGLDefault nixGLType)
      ++ [
        inputs.nur.overlays.default
      ]
      ++ builtins.attrValues outputs.overlays;
    };

  forAllSystems = lib.genAttrs systems;

  # Home Manager standalone (Debian, Fedora, etc.).
  #   hostname     carrega home-manager/hosts/<hostname>
  #   desktop      "bspwm" | "dwm" | "hyprland" | "mangowm" | "xfce4" | null (null = sem desktop)
  #   waylandShell "traditional" | "noctalia"
  #   useNixGL     envolve apps gráficos com nixGL (distros não-NixOS)
  #   nixGLType    "intel" | "mesa" | "auto" | "nvidia" | null (ver lib/nixgl/default.nix)
  mkHome =
    {
      hostname,
      username ? defaults.username,
      desktop ? null,
      waylandShell ? "traditional",
      platform ? defaults.platform,
      stateVersion ? "26.05",
      useNixGL ? true,
      nixGLType ? null,
      isISO ? false,
    }:
    let
      pkgs = mkPkgs { inherit platform nixGLType; };
      nixGLWrapper = if useNixGL then (import ./nixgl { inherit pkgs nixGLType; }).wrapper else lib.id;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs lib;
      extraSpecialArgs =
        mkCommonArgs {
          inherit
            hostname
            username
            desktop
            waylandShell
            platform
            stateVersion
            isISO
            ;
        }
        // {
          inherit useNixGL nixGLType nixGLWrapper;
          isNvidia = false;
        };
      modules = [ ../home-manager ];
    };

  # NixOS completo, com Home Manager integrado.
  #   hostid  8 hex para ZFS/rede      isVM  máquina virtual
  #   isISO   por padrão, hostname com prefixo "iso-"
  mkNixos =
    {
      hostname,
      username ? defaults.username,
      desktop ? null,
      waylandShell ? "traditional",
      platform ? defaults.platform,
      hostid ? null,
      stateVersion ? "24.11",
      isISO ? lib.hasPrefix "iso-" hostname,
      isVM ? false,
    }:
    let
      commonArgs = mkCommonArgs {
        inherit
          hostname
          username
          desktop
          waylandShell
          platform
          stateVersion
          isISO
          ;
      };
      installerModule =
        if desktop == null then "installation-cd-minimal.nix" else "installation-cd-graphical-base.nix";
    in
    lib.nixosSystem {
      specialArgs = commonArgs // {
        inherit hostid;
        notVM = !isVM;
      };
      modules = [
        ../nixos

        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            backupFileExtension = "hm.backup";
            users.${username} = import ../home-manager;
            extraSpecialArgs = commonArgs // {
              useNixGL = false;
              nixGLWrapper = lib.id;
              isNvidia = builtins.elem hostname nvidiaLegacyHosts;
            };
          };
        }
      ]
      ++ lib.optional isISO (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/${installerModule}");
    };

  # Imagem ISO (minimal ou gráfica).
  mkIso =
    {
      desktop ? null,
      platform ? defaults.platform,
      stateVersion ? "24.11",
    }:
    mkNixos {
      hostname = if desktop != null then "iso-${desktop}" else "iso-console";
      username = "nixos";
      isISO = true;
      inherit desktop platform stateVersion;
    };

  # `nix flake check`: o flake check nativo já avalia todas as nixosConfigurations.
  # Adicionamos em `checks` apenas as homeConfigurations standalone para validação completa.
  mkChecks =
    { self, ... }:
    forAllSystems (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        # drvPath sem contexto: força a avaliação mas não vira dependência de build.
        evalOnly =
          name: drv: pkgs.writeText "eval-${name}" (builtins.unsafeDiscardStringContext drv.drvPath);
        home = lib.mapAttrs' (
          name: cfg:
          lib.nameValuePair "home-${lib.replaceStrings [ "@" ] [ "-" ] name}" (
            evalOnly name cfg.activationPackage
          )
        ) self.homeConfigurations;
      in
      # Todos os hosts atuais são x86_64; evita avaliar em aarch64.
      lib.optionalAttrs (system == defaults.platform) home
    );
in
{
  inherit
    forAllSystems
    nixpkgsConfig
    mkHome
    mkNixos
    mkIso
    mkChecks
    lib
    ;
  inherit (lib) my;
}
