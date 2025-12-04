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
          # desktop = "xfce4";
          # usenixGL = true;
          # stateVersion = "24.05";
        };
      };

      nixosConfigurations = {
        virtualvm = helper.makeNixOS {
          hostname = "virtualvm";
          # desktop = "xfce4";
          # stateVersion = "24.05";
        };
      };

      # Accessible through 'nix build', 'nix shell', etc
      packages = helper.forAllSystems (system:
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


      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = helper.forAllSystems (system:
        let
          # pkgs = nixpkgs.legacyPackages.${system};
          pkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };
        in
        import ./shell.nix { inherit pkgs; }
      );
    };
}
