{
  description = "NixOS and Home Manager Configurations";

  inputs = {
    # Nix Packages
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2605.*";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
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

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      helper = import ./lib { inherit inputs outputs; };
    in
    {
      homeConfigurations = {
        # Workstations
        "juca@rocinante" = helper.mkHome {
          hostname = "rocinante";
          desktop = "bspwm";
        };

        # VMs & Hosts
        "juca@fedora" = helper.mkHome {
          hostname = "fedora";
          desktop = "bspwm";
        };
        "juca@anubis" = helper.mkHome {
          hostname = "anubis";
          desktop = "bspwm";
        };
        "juca@virtualvm" = helper.mkHome {
          hostname = "virtualvm";
          stateVersion = "24.05";
        };
        "juca@anubisvm" = helper.mkHome {
          hostname = "anubisvm";
          desktop = "bspwm";
        };
      };

      # Full NixOS System configurations (includes integrated Home-Manager)
      # Usage: sudo nixos-rebuild switch --flake .#hostname
      nixosConfigurations = {
        # Workstations
        rocinante = helper.mkNixos {
          hostname = "rocinante";
          desktop = "bspwm";
          stateVersion = "22.11";
        };

        # Generic & Minimal Live ISOs
        iso-xfce4 = helper.mkIso { desktop = "xfce4"; };
        iso-gnome = helper.mkIso { desktop = "gnome"; };
        iso-mate = helper.mkIso { desktop = "mate"; };
        iso-pantheon = helper.mkIso { desktop = "pantheon"; };
        iso-bspwm = helper.mkIso { desktop = "bspwm"; };
        iso-console = helper.mkIso { desktop = null; };

        # MacBook Pro 4,1 specific ISO (fixes 32-bit EFI boot + Apple hardware)
        iso-rocinante = helper.mkNixos {
          hostname = "iso-rocinante";
          desktop = "xfce4";
          stateVersion = "24.11";
          isISO = true;
        };
      };

      # Development environment
      devShells = helper.forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        import ./shell.nix { inherit pkgs; }
      );

      # Custom packages & modifications exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Custom packages accessible via 'nix build .#package'
      packages = helper.forAllSystems (
        system:
        let
          pkgsWithOverlays = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = builtins.attrValues self.overlays;
          };
        in
        (import ./pkgs) pkgsWithOverlays
      );

      # Formatter for .nix files ('nix fmt')
      formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      # Automated checks run via 'nix flake check'
      checks = helper.mkChecks { inherit self inputs; };
    };
}
