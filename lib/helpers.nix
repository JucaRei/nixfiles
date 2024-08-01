{ inputs, outputs, stateVersion, lib, pkgs, config, ... }:
let
  nixGLWrap = pkgs: pkg:
    let
      bins = "${pkg}/bin";
    in
    pkgs.buildEnv {
      name = "nixGL-${pkg.name}";
      paths =
        [ pkg ] ++
        (map
          (bin: pkgs.hiPrio (
            pkgs.writeShellScriptBin bin ''
              exec -a "$0" "${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL" "${bins}/${bin}" "$@"
            ''
          ))
          (builtins.attrNames (builtins.readDir bins)));
    };
in
{
  # Helper function for generating home-manager configs
  mkHome =
    ### TODO - add displays
    { hostname, username ? "juca", desktop ? null, stateVersion ? "23.11", platform ? "x86_64-linux" }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isLima = builtins.substring 0 5 hostname == "lima-";
      isWorkstation = builtins.isString desktop;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion isInstall isLima isISO isWorkstation nixGLWrap;
      };
      modules = [
        ({ config, pkgs, lib, ... }: {
          # Shared Between all users
          services.vscode-server = {
            enable = lib.mkDefault false;
          };
          home.packages = with pkgs; [
            nixpkgs-fmt
            nix-output-monitor
          ];
        })
        inputs.declarative-flatpak.homeManagerModules.default
        inputs.nur.hmModules.nur
        inputs.vscode-server.homeModules.default
        # inputs.vscode-server.nixosModules.home
        ../home-manager
      ];
    };

  # Helper function for generating host configs
  mkHost =
    { hostname, username ? "juca", desktop ? null, hostid ? null, platform ? "x86_64-linux", stateVersion ? "23.11", }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isLima = builtins.substring 0 5 hostname == "lima-";
      isWorkstation = builtins.isString desktop;
      notVM = if (hostname == "minimech") || (hostname == "scrubber") || (hostname == "vm") || (builtins.substring 0 5 hostname == "lima-") then false else true;
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs desktop hostname platform username hostid stateVersion isInstall isLima isISO notVM isWorkstation;
      };
      modules =
        let
          cd-dvd =
            if (desktop == null) then
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            else
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
        in
        [
          ../nixos
          # inputs.chaotic.nixosModules.default # DEFAULT MODULE
          # inputs.home-manager.nixosModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.users.${username} = import ../home-manager;

          #   # Optionally, use home-manager.extraSpecialArgs to pass
          #   # arguments to home.nix
          # }
          inputs.proxmox-nixos.nixosModules.proxmox-ve
          inputs.disko.nixosModules.disko
          inputs.nh.nixosModules.default
          inputs.catppuccin.nixosModules.catppuccin
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.nix-index-database.nixosModules.nix-index
          inputs.nix-snapd.nixosModules.default
          inputs.sops-nix.nixosModules.sops
          ({ pkgs, lib, inputs, config, ... }: {
            # Shared Between all users
            # services.proxmox-ve.enable = true;
            nixpkgs.overlays = [
              inputs.proxmox-nixos.overlays.${platform}
            ];
          })
        ]
        ++ inputs.nixpkgs.lib.optionals (isISO) [ cd-dvd ];
    };

  systems = inputs.nixpkgs.lib.genAttrs [
    "x86_64-linux"
    "aarch64-linux"
    "i686-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  nixGLWrapper =
    pkgs:
    { pkg
    , nixGL ? pkgs.nixgl.nixGLMesa
    }:
    pkgs.symlinkJoin {
      inherit (pkg) meta;

      name = "nixGL-${lib.getName pkg}";
      paths = [ pkg ];

      nativeBuildInputs = with pkgs; [ makeWrapper ];

      passthru.unwrapped = pkg;

      postBuild = ''
        mkdir -p $out/share/nixgl
        # Delete lines that start with exec
        cat '${lib.getExe nixGL}' | sed '/^exec/d' > $out/share/nixgl/env

        (
          # Prevent loop from running if no files
          shopt -s nullglob

          # Wrap programs in nixGL by loading the nixGL environment variables
          for bin in "$out/bin/"*; do
            wrapProgram "$bin" --run ". $out/share/nixgl/env"
          done

          # Fix desktop entries to point to the new binaries, if needed
          for desktop in "$out/share/applications/"*".desktop"; do
            sed -i "s|${pkg}|$out|g" "$desktop"
          done
        )
      '';
    };
}
