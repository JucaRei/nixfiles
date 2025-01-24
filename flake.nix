{
  description = "NixOS, nix-darwin and Home Manager Configuration";
  inputs = {
    nixpkgs-oldstable.url = "https://flakehub.com/f/nixos/nixpkgs/0.2405.*";
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2411.*";
    nixpkgs-unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    catppuccin.url = "github:catppuccin/nix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager_unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager_oldstable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-oldstable";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-needsreboot = {
      url = "https://codeberg.org/Mynacol/nixos-needsreboot/archive/0.2.2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional but recommended to limit the size of your system closure.
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # FlakeHub
    catppuccin-vsc = {
      url = "https://flakehub.com/f/catppuccin/vscode/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0";

    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/0";

    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*.tar.gz";

    nix-snapd = {
      url = "https://flakehub.com/f/io12/nix-snapd/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SFMono w/ patches
    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
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
      # home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles
      # home-manager switch -b backup --flake $FLAKE
      # nix run nixpkgs#home-manager -- switch -b backup --flake "${HOME}/.dotfiles/nixfiles"
      # nom build -- switch -b backup --flake "${HOME}/.dotfiles/nixfiles"
      # nom build .#homeConfigurations.${username@hostname}.activationPackage --impure --show-trace -vL
      homeConfigurations = {
        # .iso images
        "nixos@iso-console" = helper.mkHome { hostname = "iso-console"; username = "nixos"; };
        "nixos@iso-gnome" = helper.mkHome { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        "nixos@iso-mate" = helper.mkHome { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        "nixos@iso-pantheon" = helper.mkHome { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };
        # Workstations
        "juca@phasma" = helper.mkHome { hostname = "phasma"; desktop = "hyprland"; };
        "juca@vader" = helper.mkHome { hostname = "vader"; desktop = "hyprland"; };
        "juca@shaa" = helper.mkHome { hostname = "shaa"; desktop = "hyprland"; };
        "juca@tanis" = helper.mkHome { hostname = "tanis"; desktop = "hyprland"; };
        "juca@nitro" = helper.mkHome { hostname = "nitro"; desktop = "xfce4"; };
        "juca@rocinante" = helper.mkHome { hostname = "rocinante"; desktop = "xfce4"; };
        # palpatine/sidious are dual boot hosts, WSL2/Ubuntu and NixOS respectively.
        "juca@palpatine" = helper.mkHome { hostname = "palpatine"; };
        "juca@sidious" = helper.mkHome { hostname = "sidious"; desktop = "gnome"; };
        # Servers
        "juca@revan" = helper.mkHome { hostname = "revan"; };
        # Steam Deck
        "deck@steamdeck" = helper.mkHome { hostname = "steamdeck"; username = "deck"; };
        # VMs
        "juca@minimech" = helper.mkHome { hostname = "minimech"; };
        "juca@scrubber" = helper.mkHome { hostname = "scrubber"; desktop = "bspwm"; };
        # Apple
        # "juca@momin" = helper.mkHome { hostname = "momin"; platform = "aarch64-darwin"; desktop = "aqua"; };
        # "juca@krall" = helper.mkHome { hostname = "krall"; platform = "x86_64-darwin"; desktop = "aqua"; };
      };
      nixosConfigurations = {
        ## Examples ##
        # nix run github:numtide/nixos-anywhere -- --build-on-remote --flake /home/juca/Documents/workspace/gitea/nixsystem#vm root@192.168.2.175
        # nix run github:numtide/nixos-anywhere -- --flake /home/juca/.dotfiles/nixfiles#air root@192.168.1.76
        # nix run github:numtide/nixos-anywhere -- --flake $FLAKE#air root@192.168.1.76
        # nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        # nom build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage

        # .iso images
        iso-console = helper.mkNixos { hostname = "iso-console"; username = "nixos"; };
        iso-gnome = helper.mkNixos { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        iso-mate = helper.mkNixos { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        iso-pantheon = helper.mkNixos { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };

        # Workstations
        #  - sudo nixos-rebuild boot --flake $HOME/.dotfiles/nixfiles
        #  - sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles
        #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel
        phasma = helper.mkNixos { hostname = "phasma"; desktop = "hyprland"; };
        tanis = helper.mkNixos { hostname = "tanis"; desktop = "hyprland"; };
        sidious = helper.mkNixos { hostname = "sidious"; desktop = "gnome"; };
        rocinante = helper.mkNixos { hostname = "rocinante"; desktop = "xfce4"; };
        nitro = helper.mkNixos { hostname = "nitro"; desktop = "xfce4"; };

        # Servers
        soyoz = helper.mkNixos { hostname = "soyoz"; };
        revan = helper.mkNixos { hostname = "revan"; };

        # VMs
        soyoz-vm = helper.mkNixos { hostname = "soyoz-vm"; desktop = null; };
        scrubber = helper.mkNixos { hostname = "scrubber"; desktop = "bspwm"; };
      };

      #nix run nix-darwin -- switch --flake ~/Zero/nix-config
      #nix build .#darwinConfigurations.{hostname}.config.system.build.toplevel
      # darwinConfigurations = {
      #   momin = helper.mkDarwin { hostname = "momin"; };
      #   krall = helper.mkDarwin { hostname = "krall"; platform = "x86_64-darwin"; };
      # };

      #  System-Manager configurations
      # nix run .#systemCOnfigs.{$hostname}.config.system.build.toplevel
      # nom build .#systemCOnfigs.{$hostname}.config.system.build.toplevel
      systemConfigs = {
        minimech = helper.mkSystemManager { };
      };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = helper.forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./shell.nix {
          inherit pkgs;
          # node = pkgs.callPackage ./shells/node { };
        }
      );

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = helper.forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
      # nom-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'

      # Formatter for .nix files, available via 'nix fmt' #nixfmt-rfc-style
      # formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-plus);
    };
}

# 8086:3185 igpu
# 8086:3198 audio
