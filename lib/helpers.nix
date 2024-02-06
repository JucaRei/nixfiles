{ inputs, outputs, stateVersion, nixgl, ... }:
let
  forEachSystem = inputs.nixpkgs.lib.genAttrs [
    "x86_64-darwin"
    "i686-linux"
    "aarch64-linux"
    "x86_64-linux"
  ];
in {
  # Helper function for generating home-manager configs
  mkHome =
    ### TODO - add displays
    { hostname, username, desktop ? null, platform ? forEachSystem }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion
          nixgl;
      };
      modules = if platform != "aarch64-linux" || "aarch64-darwin" then [
        inputs.flatpaks.homeManagerModules.default
        ./nixgl.nix
        ../home-manager
      ] else
        [ ../home-manager ];
    };

  # Helper function for generating host configs
  mkHost =
    { hostname, username, desktop ? null, hostid ? null, installer ? null, }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs desktop hostname username hostid stateVersion;
      };
      modules = [ ../nixos ]
        ++ (inputs.nixpkgs.lib.optionals (installer != null) [ installer ]);
    };

  systems = inputs.nixpkgs.lib.genAttrs [
    "i686-linux"
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];
}
