{
  description = "My NixOS, nix-darwin and Home Manager Configuration";
  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0";
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/0";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2411.*";
    nixpkgs-unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "https://flakehub.com/f/catppuccin/nix/*";
    catppuccin-vsc = {
      url = "https://flakehub.com/f/catppuccin/vscode/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "https://flakehub.com/f/nix-community/disko/1.11.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "https://flakehub.com/f/NixOS/nixos-hardware/*";
    nixos-needsreboot = {
      url = "https://flakehub.com/f/wimpysworld/nixos-needsreboot/0.2.3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*";
    nix-snapd = {
      url = "https://flakehub.com/f/io12/nix-snapd/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickemu = {
      url = "https://flakehub.com/f/quickemu-project/quickemu/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickgui = {
      url = "https://flakehub.com/f/quickemu-project/quickgui/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "https://flakehub.com/f/Mic92/sops-nix/0.1.887.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stream-sprout = {
      url = "https://flakehub.com/f/wimpysworld/stream-sprout/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, nix-darwin, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "24.11";
      helper = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # home-manager build --flake $HOME/Zero/nix-config -L
      # home-manager switch -b backup --flake $HOME/Zero/nix-config
      # nix run nixpkgs#home-manager -- switch -b backup --flake "${HOME}/Zero/nix-config"
      homeConfigurations = {
        # .iso images
        "nixos@iso-console" = helper.mkHome {
          hostname = "iso-console";
          username = "nixos";
        };
        "nixos@iso-gnome" = helper.mkHome {
          hostname = "iso-gnome";
          username = "nixos";
          desktop = "gnome";
        };
        "nixos@iso-lomiri" = helper.mkHome {
          hostname = "iso-lomiri";
          username = "nixos";
          desktop = "lomiri";
        };

        "nixos@iso-mate" = helper.mkHome {
          hostname = "iso-mate";
          username = "nixos";
          desktop = "mate";
        };
        "nixos@iso-pantheon" = helper.mkHome {
          hostname = "iso-pantheon";
          username = "nixos";
          desktop = "pantheon";
        };
        # Workstations
        "juca@nitro" = helper.mkHome {
          hostname = "nitro";
          desktop = "hyprland";
        };
        # palpatine/sidious are dual boot hosts, WSL2/Ubuntu and NixOS respectively.
        "juca@nitrowin" = helper.mkHome { hostname = "nitrowin"; };
        "juca@vm" = helper.mkHome {
          hostname = "vm";
          desktop = "gnome";
        };
        # Servers
        "juca@zion" = helper.mkHome { hostname = "zion"; };
        # Steam Deck
        "deck@steamdeck" = helper.mkHome {
          hostname = "steamdeck";
          username = "deck";
        };
        # VMs
        "juca@blackace" = helper.mkHome { hostname = "blackace"; };
        "juca@defender" = helper.mkHome { hostname = "defender"; };
        "juca@dagger" = helper.mkHome {
          hostname = "dagger";
          desktop = "pantheon";
        };
      };
      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-gnome}.config.system.build.isoImage
        iso-console = helper.mkNixos {
          hostname = "iso-console";
          username = "nixos";
        };
        iso-gnome = helper.mkNixos {
          hostname = "iso-gnome";
          username = "nixos";
          desktop = "gnome";
        };
        iso-lomiri = helper.mkNixos {
          hostname = "iso-lomiri";
          username = "nixos";
          desktop = "lomiri";
        };

        iso-mate = helper.mkNixos {
          hostname = "iso-mate";
          username = "nixos";
          desktop = "mate";
        };
        iso-pantheon = helper.mkNixos {
          hostname = "iso-pantheon";
          username = "nixos";
          desktop = "pantheon";
        };
        # Workstations
        #  - sudo nixos-rebuild boot --flake $HOME/Zero/nix-config
        #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
        #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel
        #  - nix run github:nix-community/nixos-anywhere -- --flake '.#{hostname}' root@{ip-address}
        nitro = helper.mkNixos {
          hostname = "nitro";
          desktop = "hyprland";
        };
        # Servers
        malak = helper.mkNixos { hostname = "malak"; };
        revan = helper.mkNixos { hostname = "revan"; };
        # VMs
        crawler = helper.mkNixos { hostname = "crawler"; };
        dagger = helper.mkNixos {
          hostname = "dagger";
          desktop = "pantheon";
        };
      };
      #nix run nix-darwin -- switch --flake ~/Zero/nix-config
      #nix build .#darwinConfigurations.{hostname}.config.system.build.toplevel
      darwinConfigurations = {
        momin = helper.mkDarwin {
          hostname = "momin";
        };
        dev = helper.mkDarwin {
          hostname = "dev";
          platform = "x86_64-darwin";
        };
      };
      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Custom NixOS modules
      nixosModules = import ./modules/nixos;
      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = helper.forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for .nix files, available via 'nix fmt'
      formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      # formatter = helper.forAllSystems (system:
      #   nix-formatter-pack.lib.mkFormatter {
      #     pkgs = nixpkgs.legacyPackages.${system};
      #     config.tools = {
      #       alejandra.enable = false;
      #       deadnix.enable = true;
      #       nixpkgs-fmt.enable = true;
      #       statix.enable = true;
      #     };
      #   }
      # );

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = helper.forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.callPackage ./shell.nix { };
          node = pkgs.callPackage ./shell/node.nix { };
        }
        # in import ./shell.nix { inherit pkgs; }
      );
    };
}
