{
  description = "NixOS and Home Manager Configurations";

  inputs = {
    # Nix Packages
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2605.*";
    nixpkgs-unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";
    nixpkgs-oldstable.url = "https://flakehub.com/f/nixos/nixpkgs/0.2405.*";

    # Home-Manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Custom Tooling & Databases
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    nixos-hardware.url = "https://flakehub.com/f/NixOS/nixos-hardware/*";
    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*.tar.gz";
    nur.url = "github:nix-community/nur";
    nixos-needsreboot.url = "https://flakehub.com/f/wimpysworld/nixos-needsreboot/*.tar.gz";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixgl";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
    auto-cpufreq.url = "github:AdnanHodzic/auto-cpufreq";
    auto-cpufreq.inputs.nixpkgs.follows = "nixpkgs-unstable";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nix4vscode.url = "github:nix-community/nix4vscode";
    nix4vscode.inputs.nixpkgs.follows = "nixpkgs-unstable";

    sf-mono-liga-src.url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
    sf-mono-liga-src.flake = false;
  };


  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      helper = import ./lib { inherit inputs outputs; };
    in
    {
      homeConfigurations = {
        # nix-shell -p home-manager.out --run 'home-manager switch -b backup --flake . --show-trace --impure'

        # .iso images
        # "nixos@iso-console" = helper.mkHome { hostname = "iso-console"; username = "nixos"; };
        # "nixos@iso-gnome" = helper.mkHome { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        # "nixos@iso-mate" = helper.mkHome { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        # "nixos@iso-pantheon" = helper.mkHome { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };

        # Workstations
        # "juca@nitro" = helper.mkHome { hostname = "nitro"; desktop = "xfce4"; };
        # "juca@anubis" = helper.mkHome {
        #   hostname = "anubis";
        #   desktop = "xfce4";
        #   useNixGL = true;
        #   stateVersion = "24.05";
        # };
        "juca@rocinante" = helper.mkHome {
          hostname = "rocinante";
          desktop = "xfce4";
          useNixGL = true;
          stateVersion = "26.05";
        };

        # VMs & Hosts
        "juca@fedora" = helper.mkHome { hostname = "fedora"; desktop = "bspwm"; useNixGL = true; stateVersion = "26.05"; };
        "juca@anubis" = helper.mkHome { hostname = "anubis"; desktop = "bspwm"; useNixGL = true; stateVersion = "26.05"; };
        "juca@virtualvm" = helper.mkHome {
          hostname = "virtualvm";
          # desktop = "xfce4";
          useNixGL = true;
          stateVersion = "24.05";
        };
        "juca@anubisvm" = helper.mkHome { hostname = "anubisvm"; desktop = "bspwm"; useNixGL = true; };
      };

      # Full NixOS System configurations (includes integrated Home-Manager)
      # Usage: sudo nixos-rebuild switch --flake .#hostname
      nixosConfigurations = {
        ## Examples ##
        # nix run github:numtide/nixos-anywhere -- --build-on-remote --flake /home/juca/Documents/workspace/gitea/nixsystem#vm root@192.168.2.175
        # nix run github:numtide/nixos-anywhere -- --flake /home/juca/.dotfiles/nixfiles#air root@192.168.1.76
        # nix run github:numtide/nixos-anywhere -- --flake $FLAKE#air root@192.168.1.76
        # nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        # nom build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage

        #  - sudo nixos-rebuild boot --flake $HOME/.dotfiles/nixfiles
        #  - sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles
        #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel

        # Workstations
        rocinante = helper.mkNixos {
          hostname = "rocinante";
          desktop = "xfce4";
          stateVersion = "24.11";
        };
      };

      # Development environment
      devShells = helper.forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };
        in
        import ./shell.nix { inherit pkgs; }
      );

      # Custom packages & modifications exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Custom packages accessible via 'nix build .#package'
      packages = helper.forAllSystems (system:
        let
          pkgsWithOverlays = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
            overlays = builtins.attrValues self.overlays;
          };
        in
        (import ./pkgs) pkgsWithOverlays
      );

      # Formatter for .nix files ('nix fmt')
      formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      # Automated checks run via 'nix flake check'
      checks = helper.mkChecks { inherit self inputs; };
    };
}
