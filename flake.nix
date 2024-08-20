{
  description = "Juca's nix flake for my system's";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs-legacy = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

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
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-needtoreboot = {
      url = "github:thefossguy/nixos-needsreboot";
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

    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # FlakeHub
    catppuccin-vsc = {
      url = "https://flakehub.com/f/catppuccin/vscode/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0";
    nur.url = "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules

    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*.tar.gz";

    nix-snapd = {
      url = "https://flakehub.com/f/io12/nix-snapd/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickemu = {
      url = "https://flakehub.com/f/quickemu-project/quickemu/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickgui = {
      url = "https://flakehub.com/f/quickemu-project/quickgui/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # inputs@  deconstructed function args
  outputs = inputs@{ self, ... }:
    with inputs; let
      inherit (self) outputs;
      # stateVersion = "23.11"; # default
      helper = import ./lib { inherit inputs outputs stateVersion lib pkgs config; };
    in
    {
      # home-manager switch -b backup --flake $HOME/Zero/nix-config
      # nix run nixpkgs#home-manager -- switch -b backup --flake "${HOME}/Zero/nix-config"
      homeConfigurations = {
        # .iso images
        "nixos@iso-console" = helper.makeHome { hostname = "iso-console"; username = "nixos"; };
        "nixos@iso-gnome" = helper.makeHome { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        "nixos@iso-mate" = helper.makeHome { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        "nixos@iso-pantheon" = helper.makeHome { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };
        # Workstations
        "juca@oldarch" = helper.makeHome { hostname = "oldarch"; desktop = null; };
        "juca@phasma" = helper.makeHome { hostname = "phasma"; desktop = "pantheon"; };
        "juca@vader" = helper.makeHome { hostname = "vader"; desktop = "pantheon"; };
        "juca@shaa" = helper.makeHome { hostname = "shaa"; desktop = "gnome"; };
        "juca@tanis" = helper.makeHome { hostname = "tanis"; desktop = "gnome"; };
        # darwin systems
        "juca@momin" = helper.makeHome { hostname = "momin"; platform = "aarch64-darwin"; desktop = "aqua"; };
        "juca@krall" = helper.makeHome { hostname = "krall"; platform = "x86_64-darwin"; desktop = "aqua"; };
        # palpatine/sidious are dual boot hosts, WSL2/Ubuntu and NixOS respectively.
        "juca@palpatine" = helper.makeHome { hostname = "palpatine"; };
        "juca@sidious" = helper.makeHome { hostname = "sidious"; desktop = "gnome"; };
        # Servers
        "juca@revan" = helper.makeHome { hostname = "revan"; };
        "juca@soyoz" = helper.makeHome { hostname = "soyoz"; };
        # Steam Deck
        "deck@steamdeck" = helper.makeHome { hostname = "steamdeck"; username = "deck"; };
        # VMs
        "juca@minimech" = helper.makeHome { hostname = "minimech"; };
        "juca@scrubber" = helper.makeHome { hostname = "scrubber"; desktop = "pantheon"; };
        "juca@lima-builder" = helper.makeHome { hostname = "lima-builder"; };
        "juca@lima-default" = helper.makeHome { hostname = "lima-default"; };
      };
      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        iso-console = helper.makeSystem { hostname = "iso-console"; username = "nixos"; };
        iso-gnome = helper.makeSystem { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        iso-mate = helper.makeSystem { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        iso-pantheon = helper.makeSystem { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };
        # Workstations
        #  - sudo nixos-rebuild boot --flake $HOME/Zero/nix-config
        #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
        #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel
        phasma = helper.makeSystem { hostname = "phasma"; desktop = "pantheon"; };
        vader = helper.makeSystem { hostname = "vader"; desktop = "pantheon"; };
        shaa = helper.makeSystem { hostname = "shaa"; desktop = "gnome"; };
        tanis = helper.makeSystem { hostname = "tanis"; desktop = "gnome"; };
        sidious = helper.makeSystem { hostname = "sidious"; desktop = "gnome"; };
        # Servers
        revan = helper.makeSystem { hostname = "revan"; };
        # VMs
        minimech = helper.makeSystem { hostname = "minimech"; };
        scrubber = helper.makeSystem { hostname = "scrubber"; desktop = "pantheon"; };
      };
      #nix run nix-darwin -- switch --flake ~/Zero/nix-config
      #nix build .#darwinConfigurations.{hostname}.config.system.build.toplevel
      darwinConfigurations = {
        momin = helper.mkDarwin { hostname = "momin"; };
        krall = helper.mkDarwin { hostname = "krall"; platform = "x86_64-darwin"; };
      };

      # nix develop -c {fish,zsh,bash}
      devShells = helper.systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./shell.nix { inherit pkgs; }
      );

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays {
        inherit inputs;
        nixgl = nixgl.overlay;
      };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = helper.systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; });

      ## nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
    };
}
