{ inputs, outputs, stateVersion, pkgs, config, lib, ... }:
with inputs;

{
  # Helper function for generating home-manager configs
  makeHomeManager =
    ### TODO - add displays
    { hostname
    , username ? "juca"
    , desktop ? null
    , stateVersion ? "24.05"
    , platform ? "x86_64-linux"
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isLima = builtins.substring 0 5 hostname == "lima-";
      isWorkstation = builtins.isString desktop;
    in
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion isInstall isLima isISO isWorkstation;
      };
      modules = [
        ../home-manager
        declarative-flatpak.homeManagerModules.default
        nur.hmModules.nur
        vscode-server.homeModules.default
        nix-index-database.hmModules.nix-index
        catppuccin.homeManagerModules.catppuccin
        # inputs.vscode-server-hm.nixosModules.home
        # "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
        ({ config, pkgs, lib, ... }: {
          # Shared Between all users
          # services.vscode-server = {
          #   enable = lib.mkDefault false;
          # };
          home.packages = with pkgs; [
            nixpkgs-fmt
            nixd
            nil
            nh
            nix-output-monitor
          ];
        })

      ];
    };

  # Helper function for generating host configs
  makeNixOS =
    { hostname
    , username ? "juca"
    , desktop ? null
    , hostid ? null
    , platform ? "x86_64-linux"
    , stateVersion ? "24.05"
    ,
    }:
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
              nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            else
              nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
        in
        [
          ############################
          ### Import nixos modules ###
          ############################

          ../nixos
          # chaotic.nixosModules.default # DEFAULT MODULE
          # home-manager.nixosModules.home-manager
          # {
          #   home-manager = {
          #     useGlobalPkgs = true;
          #     useUserPackages = true;
          #     users.${username} = {
          #       home.username = "${username}";
          #       home.homeDirectory = "/home/${username}";
          #       imports = [ ../home-manager ];
          #     };
          #     extraSpecialArgs = {
          #       inherit inputs outputs desktop hostname platform username hostid stateVersion isInstall isLima isISO notVM isWorkstation;
          #     };
          #   };
          #   # Optionally, use home-manager.extraSpecialArgs to pass
          #   # arguments to home.nix
          # }
          proxmox-nixos.nixosModules.proxmox-ve
          chaotic.nixosModules.default
          disko.nixosModules.disko
          nh.nixosModules.default
          catppuccin.nixosModules.catppuccin
          nix-flatpak.nixosModules.nix-flatpak
          nix-index-database.nixosModules.nix-index
          nix-snapd.nixosModules.default
          sops-nix.nixosModules.sops
          ({ pkgs, lib, inputs, config, ... }: {
            # Shared Between all users
            # services.proxmox-ve.enable = true;
            nixpkgs. overlays = [
              inputs.proxmox-nixos.overlays.${ platform}
            ];
          })

        ] ++ inputs.nixpkgs.lib.optionals (isISO) [
          cd-dvd
          ### Build ISO with vscode-server ###
          inputs.vscode-server.nixosModules.default
          ({ pkgs, lib, config, ... }: {
            environment = {
              systemPackages = with pkgs; [
                unstable.vscode-fhs
              ];
            };
            services.vscode-server.enable = true;
          })
        ];
    };

  systems = inputs.nixpkgs.lib.genAttrs [
    "x86_64-linux"
    "aarch64-linux"
    "i686-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
}
