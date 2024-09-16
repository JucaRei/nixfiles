{
  description = "Juca's NixOS and Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-legacy.url = "github:nixos/nixpkgs/nixos-22.11";

    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.chaotic.url = "https://flakehub.com/f/chaotic-cx/nyx/*.tar.gz";
    };

    catppuccin.url = "github:catppuccin/nix";

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cachix.url = "github:cachix/cachix";
    cachix-deploy-flake = {
      url = "github:cachix/cachix-deploy-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agenix.url = "github:ryantm/agenix";
    # agenix.inputs.nixpkgs.follows = "nixpkgs";

    # pinix.url = "github:remi-dupre/pinix";
    # pinix.inputs.nixpkgs.follows = "nixpkgs";

    # impermanence = {
    #   url = "github:nix-community/impermanence";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Handles Flatpaks.
    declarative-flatpak.url = "github:GermanBread/declarative-flatpak/stable-v3";

    # nbfc = {
    #   url = "github:nbfc-linux/nbfc-linux";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # nix-software-center = {
    #   url = "github:vlinkz/nix-software-center";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nix-formatter-pack = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    proxmox-nixos = {
      url = "github:SaumonNet/proxmox-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    ################
    ### FlakeHub ###
    ################

    nix-snapd = {
      url = "https://flakehub.com/f/io12/nix-snapd/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For home-manager
    vscode-server-hm = {
      url = "github:nix-community/nixos-vscode-server/hm-module-import";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For nixos
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    polybar-scripts = {
      url = "github:polybar/polybar-scripts";
      flake = false;
    };

    # Neovim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gaming tweaks
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Use nix-index without having to generate the database locally
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # darwin = {
    #   url = "github:lnl7/nix-darwin/master"; # MacOS Package Management
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nur.url = "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules

    # picom.url = "github:yaocccc/picom";
    # spicetify-nix.url = "github:the-argus/spicetify-nix";
    # nixos-generators.url = "github:NixOS/nixos-hardware/master";
    # robotnix.url = "github:danielfullmer/robotnix";

    #emacs-overlay = {
    #  # Emacs Overlays
    #  url = "github:nix-community/emacs-overlay";
    #  flake = false;
    #};

    # nix-on-droid = {
    #   url = "github:t184256/nix-on-droid";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    comma.url = "github:nix-community/comma/v1.4.1";

    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # More up to date auto-cpufreq
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #doom-emacs = {
    #  # Nix-community Doom Emacs
    #  url = "github:nix-community/nix-doom-emacs";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.emacs-overlay.follows = "emacs-overlay";
    #};

    nixos-needtoreboot = {
      url = "github:thefossguy/nixos-needsreboot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland"; # <- make sure this line is present for the plugin to work as intended
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lf-icons = {
      url = "github:gokcehan/lf";
      flake = false;
    };

    plasma-manager = {
      # KDE Plasma user settings
      url = "github:pjones/plasma-manager"; # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to the home-manager.users.${user}.imports
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "nixpkgs";
    };

    # devenv.url = "github:cachix/devenv";
    # budgie = {
    #   url = "github:FedericoSchonborn/budgie-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://cachix.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # inputs@  deconstructed function args
  outputs = inputs@{ self, ... }:
    with inputs; let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      # stateVersion = "23.11"; # default
      helper = import ./lib { inherit inputs outputs stateVersion lib pkgs config; };

    in
    {
      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = helper.systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; });

      ## nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = helper.systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./shell.nix {
          inherit pkgs;
          # node = pkgs.callPackage ./shells/node { };
        }
      );

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays {
        inherit inputs;
        nixgl = nixgl.overlay;
      };

      # nix fmt
      formatter = helper.systems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        });

      ### Separated home-manager from nixos
      homeConfigurations =
        {
          # home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles
          # home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles
          # nix build .#homeConfigurations."juca@DietPi".activationPackage
          # nom build .#homeConfigurations."juca@vm".activationPackage --impure
          # nom build .#homeConfigurations."juca@oldarch".activationPackage --impure --show-trace -L
          "juca@nitro" = helper.makeHomeManager {
            hostname = "nitro";
            # desktop = "bspwm";
            stateVersion = "24.05";
          };
          "juca@air" = helper.makeHomeManager { hostname = "air"; desktop = "bspwm"; stateVersion = "24.05"; };
          "juca@anubis" = helper.makeHomeManager { hostname = "anubis"; desktop = "bspwm"; };
          "juca@oldarch" = helper.makeHomeManager { hostname = "oldarch"; desktop = "xfce"; stateVersion = "23.05"; };
          "juca@nitrovoid" = helper.makeHomeManager { hostname = "nitrovoid"; };
          "juca@soyo" = helper.makeHomeManager { hostname = "soyo"; stateVersion = "24.05"; };
          "juca@rocinante" = helper.makeHomeManager { hostname = "rocinante"; desktop = "mate"; };
          "juca@rocinante-headless" = helper.makeHomeManager { hostname = "rocinante"; desktop = null; };
          "juca@vortex" = helper.makeHomeManager { hostname = "vortex"; };
          # Testing
          "juca@hyperv" = helper.makeHomeManager { hostname = "hyperv"; desktop = "mate"; };
          "juca@voidvm" = helper.makeHomeManager { hostname = "voidvm"; };
          "juca@debianvm" = helper.makeHomeManager { hostname = "debianvm"; desktop = "bspwm"; };
          # Wsl
          "juca@nitrowin" = helper.makeHomeManager { hostname = "nitrowin"; stateVersion = "23.11"; };
          # Raspberry 3
          "juca@DietPi" = helper.makeHomeManager { hostname = "DietPi"; desktop = null; platform = "aarch64-linux"; };
          # VMs
          "juca@scrubber" = helper.makeHomeManager { hostname = "scrubber"; desktop = "bspwm"; };
          "juca@proxmox" = helper.makeHomeManager { hostname = "proxmox"; };
          "juca@vm" = helper.makeHomeManager { hostname = "vm"; desktop = "mate"; };
          # Iso
          # "juca@iso-console" = helper.makeHomeManager { hostname = "iso-console"; username = "nixos"; };
          # "juca@iso-desktop" = helper.makeHomeManager { hostname = "iso-desktop"; username = "nixos"; desktop = "pantheon"; };
        };
      # hostids are generated using `mkhostid` alias
      nixosConfigurations = {
        # .iso images
        # - nix run github:numtide/nixos-anywhere -- --build-on-remote --flake /home/juca/Documents/workspace/gitea/nixsystem#vm root@192.168.2.175
        # nix run github:numtide/nixos-anywhere -- --flake /home/juca/.dotfiles/nixfiles#air root@192.168.1.76
        # - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        # nix build .#nixosConfigurations.iso.config.system.build.isoImage
        # nom build .#nixosConfigurations.nitro.config.system.build.toplevel

        # ISO
        iso-console = helper.makeNixOS { hostname = "iso-console"; username = "nixos"; };
        iso-gnome = helper.makeNixOS { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; hostid = "f4173273"; };
        iso-mate = helper.makeNixOS { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        iso-pantheon = helper.makeNixOS { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };
        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles/nixfiles
        #  - nix build .#nixosConfigurations.ripper.config.system.build.toplevel
        # Servers
        # Laptop
        nitro = helper.makeNixOS { hostname = "nitro"; desktop = "cinnamon"; stateVersion = "24.05"; }; # desktop = "hyprland";
        air = helper.makeNixOS { hostname = "air"; desktop = "pantheon"; hostid = "718641c6"; stateVersion = "22.11"; };
        soyo = helper.makeNixOS { hostname = "soyo"; stateVersion = "24.05"; desktop = "kodi"; };
        rocinante = helper.makeNixOS { hostname = "rocinante"; desktop = "mate"; hostid = "f4173273"; };
        rocinante-headless = helper.makeNixOS { hostname = "rocinante"; hostid = "836715d7"; };
        # Virtual Machines
        vm = helper.makeNixOS { hostname = "vm"; desktop = "mate"; };
        scrubber = helper.makeNixOS { hostname = "scrubber"; desktop = "mate"; };
        hyperv = helper.makeNixOS { hostname = "hyperv"; desktop = "mate"; hostid = "6f2efa51"; };
        proxmox = helper.makeNixOS { hostname = "proxmox"; desktop = null; };
        # Raspberry
        # rasp3 = helper.makeNixOS { hostname = "rasp3"; hostid = "6f2efa55"; };
      };
    };
}
