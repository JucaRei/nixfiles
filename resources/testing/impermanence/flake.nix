{
  description = "Impermanence Testing";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... } @inputs: {
    nixosConfigurations.testing = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        inputs.disko.nixosModules.testing
        ./configuration.nix
        (import ./disko.nix { device = "/dev/vda"; })
        inputs.home-manager.nixosModules.testing
        inputs.impermanence.nixosModules.impermanence
      ];
    };
  };
}
