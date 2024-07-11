{
  description = "Juca's NixOS and Home Manager Configuration";

  inputs = {
    nixpkgs-legacy.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-previous.url = "github:nixos/nixpkgs/nixos-23.05";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # You can access packages and modules from different nixpkgs revs at the same time.
    # See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    chaotic.inputs.chaotic.url = "https://flakehub.com/f/chaotic-cx/nyx/*.tar.gz";

    catppuccin.url = "github:catppuccin/nix";

    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs"; # 23.05

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    sddm-sugar-candy-nix.url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
    sddm-sugar-candy-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # cachix-deploy-flake.url = "github:cachix/cachix-deploy-flake";
    # cachix-deploy-flake.inputs.nixpkgs.follows = "nixpkgs";

    # agenix.url = "github:ryantm/agenix";
    # agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Art
    # nixos-artwork.url = "github:NixOS/nixos-artwork";
    # nixos-artwork.flake = false;

    # flatpaks.url = "github:GermanBread/declarative-flatpak/stable";

    # pinix.url = "github:remi-dupre/pinix";
    # pinix.inputs.nixpkgs.follows = "nixpkgs";

    # impermanence = {
    #   url = "github:nix-community/impermanence";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Handles Flatpaks.
    # flatpaks.url = "github:GermanBread/declarative-flatpak"; #dev
    declarative-flatpak.url = "github:GermanBread/declarative-flatpak/stable";

    # nbfc = {
    #   url = "github:nbfc-linux/nbfc-linux";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # nix-software-center.url = "github:vlinkz/nix-software-center";
    # nix-software-center.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    ################
    ### FlakeHub ###
    ################

    # antsy-alien-attack-pico = {
    #   url = "https://flakehub.com/f/wimpysworld/antsy-alien-attack-pico/*.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
    # fh.inputs.nixpkgs.follows = "nixpkgs";

    # crafts-flake.url = "https://flakehub.com/f/jnsgruk/crafts-flake/0.6.*.tar.gz";
    # crafts-flake.inputs.nixpkgs.follows = "nixpkgs";

    nix-snapd.url = "https://flakehub.com/f/io12/nix-snapd/0.1.*.tar.gz";
    nix-snapd.inputs.nixpkgs.follows = "nixpkgs";

    # nixpkgs-f2k.url = "github:moni-dz/nixpkgs-f2k";
    # nixpkgs-f2k.inputs.nixpkgs.follows = "nixpkgs";

    # vscode-server.url = "github:nix-community/nixos-vscode-server";
    # vscode-server.inputs.nixpkgs.follows = "nixpkgs";


    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs-unstable"; # "nixpkgs";
      # inputs.flake-utils.follows = "agenix-cli/flake-utils";
    };

    polybar-scripts = {
      url = "github:polybar/polybar-scripts";
      flake = false;
    };

    # Neovim
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Gaming tweaks
    nix-gaming.url = "github:fufexan/nix-gaming";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Use nix-index without having to generate the database locally
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # darwin = {
    #   url = "github:lnl7/nix-darwin/master"; # MacOS Package Management
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nur.url = "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules

    # picom.url = "github:yaocccc/picom";
    #spicetify-nix.url = "github:the-argus/spicetify-nix";
    # nixos-generators.url = "github:NixOS/nixos-hardware/master";
    # robotnix.url = "github:danielfullmer/robotnix";

    #emacs-overlay = {
    #  # Emacs Overlays
    #  url = "github:nix-community/emacs-overlay";
    #  flake = false;
    #};

    # nix-on-droid.url = "github:t184256/nix-on-droid";
    # nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";

    comma.url = "github:nix-community/comma/v1.4.1";

    wrapper-manager.url = "github:viperML/wrapper-manager";
    wrapper-manager.inputs.nixpkgs.follows = "nixpkgs";

    nh.url = "github:viperML/nh/v3.5.10";
    nh.inputs.nixpkgs.follows = "nixpkgs";

    # More up to date auto-cpufreq
    # auto-cpufreq.url = "github:AdnanHodzic/auto-cpufreq";
    # auto-cpufreq.inputs.nixpkgs.follows = "nixpkgs";

    # ttf-to-tty.url = "github:Sigmanificient/ttf_to_tty";
    # ttf-to-tty.inputs.nixpkgs.follows = "nixpkgs";

    #doom-emacs = {
    #  # Nix-community Doom Emacs
    #  url = "github:nix-community/nix-doom-emacs";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.emacs-overlay.follows = "emacs-overlay";
    #};

    nixos-needtoreboot.url = "github:thefossguy/nixos-needsreboot";
    nixos-needtoreboot.inputs.nixpkgs.follows = "nixpkgs";

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland.inputs.nixpkgs.follows = "nixpkgs-unstable";
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    hyprland-plugins.inputs.hyprland.follows = "hyprland";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    hyprpicker.inputs.nixpkgs.follows = "nixpkgs";
    split-monitor-workspaces.url = "github:Duckonaut/split-monitor-workspaces";
    split-monitor-workspaces.inputs.hyprland.follows = "hyprland"; # <- make sure this line is present for the plugin to work as intended
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

    # matugen.url = "github:InioX/matugen";
    # matugen.inputs.nixpkgs.follows = "nixpkgs";
    # ags.url = "github:Aylur/ags";
    # ags.inputs.nixpkgs.follows = "nixpkgs";
    # astal.url = "github:Aylur/astal";
    # astal.inputs.nixpkgs.follows = "github:Aylur/astal";
    # stm.url = "github:Aylur/stm";
    # stm.inputs.nixpkgs.follows = "github:Aylur/stm";

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
      libx = import ./lib { inherit inputs outputs stateVersion lib pkgs; };

    in
    {
      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = libx.systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; });

      ## nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = libx.systems (system:
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
      formatter = libx.systems (system:
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
          "juca@nitro" = libx.mkHome { hostname = "nitro"; username = "juca"; desktop = "bspwm"; stateVersion = "24.05"; };
          "juca@zion" = libx.mkHome { hostname = "zion"; username = "juca"; desktop = "bspwm"; };
          "juca@air" = libx.mkHome { hostname = "air"; username = "juca"; desktop = "bspwm"; stateVersion = "24.05"; };
          "juca@anubis" = libx.mkHome { hostname = "anubis"; username = "juca"; desktop = "bspwm"; };
          "juca@oldarch" = libx.mkHome { hostname = "oldarch"; username = "juca"; desktop = "xfce"; stateVersion = "23.05"; };
          #"juca@nitro" = libx.mkHome { hostname = "nitro"; username = "juca"; };
          "juca@nitrovoid" = libx.mkHome { hostname = "nitrovoid"; username = "juca"; };
          "juca@rocinante" = libx.mkHome { hostname = "rocinante"; username = "juca"; desktop = "mate"; };
          "juca@rocinante-headless" = libx.mkHome { hostname = "rocinante"; username = "juca"; desktop = null; };
          "juca@vortex" = libx.mkHome { hostname = "vortex"; username = "juca"; };
          # Testing
          "juca@hyperv" = libx.mkHome { hostname = "hyperv"; username = "juca"; desktop = "mate"; };
          "juca@voidvm" = libx.mkHome { hostname = "voidvm"; username = "juca"; };
          "juca@debianvm" = libx.mkHome { hostname = "debianvm"; username = "juca"; desktop = "bspwm"; };
          "juca@vm-headless" = libx.mkHome { hostname = "vm"; username = "juca"; desktop = null; };
          # Wsl
          "juca@nitrowin" = libx.mkHome { hostname = "nitrowin"; username = "juca"; stateVersion = "23.11"; };
          # Raspberry 3
          "juca@DietPi" = libx.mkHome { hostname = "DietPi"; username = "juca"; desktop = null; platform = "aarch64-linux"; };
          # VMs
          "juca@minimech" = libx.mkHome { hostname = "minimech"; username = "juca"; desktop = "bspwm"; };
          "juca@scrubber" = libx.mkHome { hostname = "scrubber"; username = "juca"; desktop = "bspwm"; };
          "juca@lima-builder" = libx.mkHome { hostname = "lima-builder"; username = "juca"; };
          "juca@lima-default" = libx.mkHome { hostname = "lima-default"; username = "juca"; };
          "juca@vm" = libx.mkHome { hostname = "vm"; username = "juca"; desktop = "mate"; };
          # Iso
          # "juca@iso-console" = libx.mkHome { hostname = "iso-console"; username = "nixos"; };
          # "juca@iso-desktop" = libx.mkHome { hostname = "iso-desktop"; username = "nixos"; desktop = "pantheon"; };
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
        iso-console = libx.mkHost { hostname = "iso-console"; username = "nixos"; };
        iso-gnome = libx.mkHost { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; hostid = "f4173273"; };
        iso-mate = libx.mkHost { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        iso-pantheon = libx.mkHost { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };
        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles/nixfiles
        #  - nix build .#nixosConfigurations.ripper.config.system.build.toplevel
        # Servers
        # Laptop
        nitro = libx.mkHost { hostname = "nitro"; username = "juca"; desktop = "bspwm"; stateVersion = "24.05"; }; # desktop = "hyprland";
        air = libx.mkHost { hostname = "air"; username = "juca"; desktop = "pantheon"; hostid = "718641c6"; stateVersion = "22.11"; };
        soyo = libx.mkHost { hostname = "soyo"; username = "juca"; stateVersion = "24.05"; };
        rocinante = libx.mkHost { hostname = "rocinante"; username = "juca"; desktop = "mate"; hostid = "f4173273"; };
        rocinante-headless = libx.mkHost { hostname = "rocinante"; username = "juca"; hostid = "836715d7"; };
        # Virtual Machines
        vm = libx.mkHost { hostname = "vm"; username = "juca"; desktop = "mate"; };
        scrubber = libx.mkHost { hostname = "scrubber"; username = "juca"; desktop = "mate"; };
        hyperv = libx.mkHost { hostname = "hyperv"; username = "juca"; desktop = "mate"; hostid = "6f2efa51"; };
        vm-headless = libx.mkHost { hostname = "vm"; username = "juca"; hostid = "04feccb5"; };
        # Raspberry
        rasp3 = libx.mkHost { hostname = "rasp3"; username = "juca"; hostid = "6f2efa55"; };
      };
    };
}
