{ inputs, outputs, ... }:

let
  inherit (inputs.nixpkgs) lib;
in
rec {

  # ============================================================================
  # mkHome: Gera configurações standalone do Home Manager (distros não-NixOS)
  # ============================================================================
  # Parâmetros:
  #   - hostname     : (String, obrigatório) Nome do host (usado para carregar hosts/${hostname} e dotfiles)
  #   - username     : (String, default: "juca") Usuário do sistema
  #   - desktop      : (String | null, default: null) Ambiente gráfico ("bspwm", "xfce4", etc). Se não nulo, ativa `isWorkstation`
  #   - platform     : (String, default: "x86_64-linux") Arquitetura do sistema alvo
  #   - stateVersion : (String, default: "26.05") Versão de compatibilidade do Home Manager (alinhado com o flake.nix)
  #   - useNixGL     : (Bool, default: true) Aplica wrapper NixGL para aceleração 3D/OpenGL em distros não-NixOS
  #   - isISO        : (Bool, default: false) Define se a configuração pertence a uma ISO live
  # ============================================================================
  mkHome =
    {
      hostname,
      username ? "juca",
      desktop ? null,
      platform ? "x86_64-linux",
      stateVersion ? "26.05",
      useNixGL ? true,
      isISO ? false,
    }:
    let
      isInstall = !isISO;
      isWorkstation = desktop != null;

      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      nixGLWrapper = if useNixGL then (import ./nixGL.nix { inherit pkgs; }).wrapper else (x: x);
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          stateVersion
          useNixGL
          isInstall
          isISO
          isWorkstation
          nixGLWrapper
          ;
      };
      modules = [
        ../home-manager
      ];
    };

  # ============================================================================
  # mkNixos: Gera configurações completas do NixOS (com Home Manager integrado)
  # ============================================================================
  # Parâmetros:
  #   - hostname     : (String, obrigatório) Hostname do sistema NixOS
  #   - username     : (String, default: "juca") Usuário principal para o Home Manager embutido
  #   - desktop      : (String | null, default: null) Ambiente de desktop do sistema
  #   - platform     : (String, default: "x86_64-linux") Arquitetura do hardware
  #   - hostid       : (String | null, default: null) Host ID para ZFS / rede (8 caracteres hexadecimais)
  #   - stateVersion : (String, default: "24.11") Versão de compatibilidade do NixOS
  #   - isISO        : (Bool, default: auto) Detecta se é ISO através do prefixo "iso-" no hostname
  #   - isVM         : (Bool, default: false) Sinaliza se a máquina roda em ambiente virtualizado
  # ============================================================================
  mkNixos =
    {
      hostname,
      username ? "juca",
      desktop ? null,
      platform ? "x86_64-linux",
      hostid ? null,
      stateVersion ? "24.11",
      isISO ? lib.hasPrefix "iso-" hostname,
      isVM ? false,
    }:
    let
      isInstall = !isISO;
      isWorkstation = desktop != null;
      notVM = !isVM;
    in
    lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          hostid
          stateVersion
          isInstall
          isISO
          isWorkstation
          notVM
          ;
      };
      modules = [
        ../nixos

        # Provisionamento automático do Home Manager durante nixos-rebuild switch
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            backupFileExtension = "hm.backup";
            users.${username} = import ../home-manager;
            extraSpecialArgs = {
              inherit
                inputs
                outputs
                desktop
                hostname
                platform
                username
                stateVersion
                isInstall
                isISO
                isWorkstation
                ;
              useNixGL = false;
              nixGLWrapper = (pkg: pkg);
            };
          };
        }
      ]
      ++ lib.optionals isISO [
        (
          if desktop == null then
            inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          else
            inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
        )
      ];
    };

  # ============================================================================
  # mkIso: Helper para gerar imagens ISO inicializáveis (minimal ou gráficas)
  # ============================================================================
  # Parâmetros:
  #   - desktop      : (String | null, default: null) Interface gráfica da ISO (ex: "xfce4", "gnome" ou null para console)
  #   - platform     : (String, default: "x86_64-linux") Arquitetura da mídia
  #   - stateVersion : (String, default: "24.11") Versão de estado
  # ============================================================================
  mkIso =
    {
      desktop ? null,
      platform ? "x86_64-linux",
      stateVersion ? "24.11",
    }:
    mkNixos {
      hostname = if desktop != null then "iso-${desktop}" else "iso-console";
      username = "nixos";
      inherit desktop platform stateVersion;
      isISO = true;
      isVM = false;
    };

  # ============================================================================
  # forAllSystems: Mapeia atributos para as arquiteturas suportadas
  # ============================================================================
  # Nota: Plataformas Darwin desabilitadas por padrão para acelerar o `nix flake check`
  # e evitar warnings de build incompatível no Linux. Reative se for compilar no macOS.
  # ============================================================================
  forAllSystems = lib.genAttrs [
    "x86_64-linux"
    "aarch64-linux"
    # "x86_64-darwin"
    # "aarch64-darwin"
  ];

  # ============================================================================
  # mkChecks: Gera checks automatizados para o `nix flake check`
  # ============================================================================
  mkChecks = { self, inputs }: forAllSystems (_system: { });
}
