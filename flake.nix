{
  description = "Wimpy's NixOS and Home Manager Configuration";
  inputs = {
    # nixpkgs-prev.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-software-center = {
      url = "github:vlinkz/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-formatter-pack = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## FlakeHub
    eza = {
      url = "https://flakehub.com/f/eza-community/eza/0.14.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fh = {
      url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gaming tweaks
    nix-gaming.url = "github:fufexan/nix-gaming";

    # hyprland.url = "github:hyprwm/Hyprland";
    # ags.url = "github:Aylur/ags";
    # lf-icons = {
    #   url = "https://raw.githubusercontent.com/gokcehan/lf/master/etc/icons.example";
    #   flake = false;
    # };

    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gaming tweaks
    # nix-gaming.url = "github:fufexan/nix-gaming";

    # Use nix-index without having to generate the database locally
    # nix-index-database = {
    #   url = "github:Mic92/nix-index-database";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # darwin = {
    #   url = "github:lnl7/nix-darwin/master"; # MacOS Package Management
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nur.url = "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules
    #spicetify-nix.url = "github:the-argus/spicetify-nix";
    #nixpkgs-f2k.url = "github:fortuneteller2k/nixpkgs-f2k";
    # nixos-generators.url = "github:NixOS/nixos-hardware/master";
    # robotnix.url = "github:danielfullmer/robotnix";

    #emacs-overlay = {
    #  # Emacs Overlays
    #  url = "github:nix-community/emacs-overlay";
    #  flake = false;
    #};

    #doom-emacs = {
    #  # Nix-community Doom Emacs
    #  url = "github:nix-community/nix-doom-emacs";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.emacs-overlay.follows = "emacs-overlay";
    #};

    #hyprland = {
    #  # Official Hyprland flake
    #  url = "github:vaxerski/Hyprland"; # Add "hyprland.nixosModules.default" to the host modules
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    # hyprland.url = "github:hyprwm/Hyprland";
    # hyprland-contrib.url = "github:hyprwm/contrib";

    #plasma-manager = {
    #  # KDE Plasma user settings
    #  url = "github:pjones/plasma-manager"; # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to the home-manager.users.${user}.imports
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.home-manager.follows = "nixpkgs";
    #};

    # budgie = {
    #   url = "github:FedericoSchonborn/budgie-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    { self
    , nixpkgs
    , disko
    , home-manager
    , nixgl
    , nix-formatter-pack
    , nixos-hardware
    , fh
    , nix-gaming
    , eza
    , vscode-server
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.05";
      libx = import ./lib { inherit inputs outputs nixgl stateVersion; };
    in
    {
      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = libx.systems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = libx.systems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix {
          inherit pkgs;
          # node = pkgs.callPackage ./shells/node { };
        }
      );

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # nix fmt
      formatter = libx.systems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );

      homeConfigurations = let inherit (builtins.currentSystem) isDarwin; in {
        # Servers
        "juca@brix" = libx.mkHome { hostname = "brix"; username = "juca"; };
        "juca@skull" = libx.mkHome { hostname = "skull"; username = "juca"; };
        # "juca@vm-mini" = libx.mkHome { hostname = "vm-mini"; username = "juca"; };
        # Steam Deck
        "deck@steamdeck" = libx.mkHome { hostname = "steamdeck"; username = "deck"; };
        # Workstations
        "juca@designare" = libx.mkHome { hostname = "designare"; username = "juca"; desktop = "pantheon"; };
        "juca@micropc" = libx.mkHome { hostname = "micropc"; username = "juca"; desktop = "pantheon"; };
        "juca@p1" = libx.mkHome { hostname = "p1"; username = "juca"; desktop = "pantheon"; };
        "juca@p2-max" = libx.mkHome { hostname = "p2-max"; username = "juca"; desktop = "pantheon"; };
        "juca@ripper" = libx.mkHome { hostname = "ripper"; username = "juca"; desktop = "pantheon"; };
        "juca@trooper" = libx.mkHome { hostname = "trooper"; username = "juca"; desktop = "pantheon"; };
        "juca@win2" = libx.mkHome { hostname = "win2"; username = "juca"; desktop = "pantheon"; };
        "juca@win-max" = libx.mkHome { hostname = "win-max"; username = "juca"; desktop = "pantheon"; };
        "juca@zed" = libx.mkHome { hostname = "zed"; username = "juca"; desktop = "pantheon"; };
        # LAPTOP
        # home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles
        # home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles
        # nix build .#homeConfigurations."juca@DietPi".activationPackage
        # "juca@nitro" = libx.mkHome { hostname = "nitro"; username = "juca"; desktop = "gnome"; };
        "juca@nitro" = libx.mkHome { hostname = "nitro"; username = "juca"; };
        "juca@nitrovoid" = libx.mkHome { hostname = "nitrovoid"; username = "juca"; };
        "juca@rocinante" = libx.mkHome { hostname = "rocinante"; username = "juca"; desktop = "mate"; };
        "juca@rocinante-headless" = libx.mkHome { hostname = "rocinante"; username = "juca"; desktop = null; };
        #"juca@air" = libx.mkHome { hostname = "air"; username = "juca"; desktop = "mate"; platform = if isDarwin then "x86_64-darwin" else "x86_64-linux"; };
        "juca@air" = libx.mkHome { hostname = "air"; username = "juca"; desktop = "bspwm"; };
        # "juca@air" = libx.mkHome { hostname = "air"; username = "juca"; };
        "juca@vortex" = libx.mkHome { hostname = "vortex"; username = "juca"; };
        # Testing
        "juca@hyperv" = libx.mkHome { hostname = "hyperv"; username = "juca"; desktop = "mate"; };
        "juca@vm" = libx.mkHome { hostname = "vm"; username = "juca"; desktop = "bspwm"; };
        "juca@voidvm" = libx.mkHome { hostname = "voidvm"; username = "juca"; desktop = "i3"; };
        "juca@debianvm" = libx.mkHome { hostname = "debianvm"; username = "juca"; desktop = "i3"; };
        "juca@vm-headless" = libx.mkHome { hostname = "vm"; username = "juca"; desktop = null; };
        # Wsl
        "juca@nitrowin" = libx.mkHome { hostname = "nitrowin"; username = "juca"; desktop = null; };
        # Raspberry 3
        "juca@DietPi" = libx.mkHome { hostname = "DietPi"; username = "juca"; desktop = null; platform = "aarch64-linux"; };
        # Iso
        # "juca@iso-console" = libx.mkHome { hostname = "iso-console"; username = "nixos"; };
        # "juca@iso-desktop" = libx.mkHome { hostname = "iso-desktop"; username = "nixos"; desktop = "pantheon"; };
      };
      # hostids are generated using `mkhostid` alias
      nixosConfigurations = {
        # .iso images
        # - nix run github:numtide/nixos-anywhere -- --flake /home/juca/Documents/workspace/gitea/nixsystem#vm root@192.168.2.175
        # - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        # nix build .#nixosConfigurations.iso.config.system.build.isoImage

        # ISO
        iso-console = libx.mkHost { hostname = "iso-console"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; hostid = "ed12be2d"; };
        iso-desktop = libx.mkHost { hostname = "iso-desktop"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; hostid = "6ade8560"; };
        iso-micropc = libx.mkHost { hostname = "micropc"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; hostid = "05af8696"; };
        iso-win2 = libx.mkHost { hostname = "win2"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; hostid = "c8f5755d"; };
        iso-win-max = libx.mkHost { hostname = "iso-win-max"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; hostid = "7683ddba"; };
        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles/nixfiles
        #  - nix build .#nixosConfigurations.ripper.config.system.build.toplevel
        designare = libx.mkHost { hostname = "designare"; username = "juca"; desktop = "pantheon"; hostid = "5588140b"; };
        p1 = libx.mkHost { hostname = "p1"; username = "juca"; desktop = "pantheon"; hostid = "3fecbbf7"; };
        p2-max = libx.mkHost { hostname = "p2-max"; username = "juca"; desktop = "pantheon"; hostid = "be5a26d8"; };
        micropc = libx.mkHost { hostname = "micropc"; username = "juca"; desktop = "pantheon"; hostid = "85fc2935"; };
        ripper = libx.mkHost { hostname = "ripper"; username = "juca"; desktop = "pantheon"; hostid = "3fba9116"; };
        trooper = libx.mkHost { hostname = "trooper"; username = "juca"; desktop = "pantheon"; hostid = "267c28e2"; };
        win2 = libx.mkHost { hostname = "win2"; username = "juca"; desktop = "pantheon"; hostid = "3cbc2743"; };
        win-max = libx.mkHost { hostname = "win-max"; username = "juca"; desktop = "pantheon"; hostid = "9ff8f5c2"; };
        zed = libx.mkHost { hostname = "zed"; username = "juca"; desktop = "pantheon"; hostid = "f2ab9451"; };
        # Servers
        brix = libx.mkHost { hostname = "brix"; username = "juca"; };
        skull = libx.mkHost { hostname = "skull"; username = "juca"; };
        # Laptop
        nitro = libx.mkHost { hostname = "nitro"; username = "juca"; desktop = "gnome"; hostid = "718643c6"; };
        air = libx.mkHost { hostname = "air"; username = "juca"; desktop = "mate"; hostid = "718641c6"; };
        rocinante = libx.mkHost { hostname = "rocinante"; username = "juca"; desktop = "mate"; hostid = "f4173273"; };
        rocinante-headless = libx.mkHost { hostname = "rocinante"; username = "juca"; hostid = "836715d7"; };
        # Virtual Machines
        vm = libx.mkHost { hostname = "vm"; username = "juca"; desktop = "bspwm"; hostid = "6f2efa51"; };
        hyperv = libx.mkHost { hostname = "hyperv"; username = "juca"; desktop = "mate"; hostid = "6f2efa51"; };
        vm-headless = libx.mkHost { hostname = "vm"; username = "juca"; hostid = "04feccb5"; };
        # Raspberry
        rasp3 = libx.mkHost { hostname = "rasp3"; username = "juca"; hostid = "6f2efa55"; };
        rasp3-headless = libx.mkHost { hostname = "rasp3-headless"; username = "juca"; hostid = "9be877f1"; };
      };
    };
}
