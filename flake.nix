{
  description = "Juca's nixos dotfiles";

  inputs = {
    ### NIXOS
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2505.*";
    nixpkgs-unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";
    nixpkgs-oldstable.url = "https://flakehub.com/f/nixos/nixpkgs/0.2311.*";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager_unstable.url = "github:nix-community/home-manager/master";
    home-manager_unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    ### Nix for darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    ### Chaotic repo
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    ### Other Custom Modules
    catppuccin.url = "github:catppuccin/nix";
    # nixos-needsreboot.url = "https://flakehub.com/f/wimpysworld/nixos-needsreboot/*.tar.gz";
    nixos-hardware.url = "https://flakehub.com/f/NixOS/nixos-hardware/*";
    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*.tar.gz";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # nixgl.url = "github:nix-community/nixGL";
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
    auto-cpufreq.url = "github:AdnanHodzic/auto-cpufreq";
    auto-cpufreq.inputs.nixpkgs.follows = "nixpkgs-unstable";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nix4vscode.url = "github:nix-community/nix4vscode";
    sf-mono-liga-src.url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized"; # SFMono w/ patches
    sf-mono-liga-src.flake = false;
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    system-manager.url = "github:numtide/system-manager";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: with inputs;
    let
      inherit (self) outputs;

      helper = import ./lib { inherit inputs outputs stateVersion pkgs; };
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      # forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      homeConfigurations = {
        "juca@virtualvm" = helper.makeHomeManager {
          hostname = "virtualvm";
          desktop = "xfce4";
          useNixGL = true;
          stateVersion = "25.05";
        };
      };
      nixosConfigurations = {
        # .iso images
        iso-console = helper.makeNixOS { hostname = "iso-console"; username = "nixos"; };
        # iso-gnome = helper.mkNixos { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        # iso-mate = helper.mkNixos { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        # iso-pantheon = helper.mkNixos { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };
        # virtualvm = helper.makeNixOS {
        #   hostname = "virtualvm";
        #   # desktop = "xfce4";
        #   # stateVersion = "24.05";
        # };
        vm = helper.makeNixOS {
          hostname = "vm";
          desktop = "pantheon";
          # stateVersion = "25.05";
        };
      };
      packages = helper.forAllSystems (system:
        # Accessible through 'nix build', 'nix shell', etc
        let
          pkgsWithOverlays = import nixpkgs {
            # Import nixpkgs for the target system, applying overlays directly
            inherit system;
            config = { allowUnfree = true; }; # Ensure consistent config
            overlays = builtins.attrValues self.overlays; # Pass the list of overlay functions directly
          };

          pkgsFunction = import ./pkgs; # Import the function from pkgs/default.nix
          customPkgs = pkgsFunction pkgsWithOverlays; # Call the function with the fully overlaid package set
        in
        customPkgs # Return the set of custom packages
      );
      formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      overlays = import ./overlays { inherit inputs; };
      devShells = helper.forAllSystems (system:
        # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
        let
          # pkgs = nixpkgs.legacyPackages.${system};
          pkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };
        in
        {
          default = (import ./shell.nix { inherit pkgs; }).default;
        }
      );
    };
}
