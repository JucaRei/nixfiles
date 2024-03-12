{ inputs, outputs, stateVersion, ... }: {
  # Helper function for generating home-manager configs
  mkHome =
    ### TODO - add displays
    { hostname, username, desktop ? null, stateVersion ? "23.11", platform ? "x86_64-linux" }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion;
      };
      modules =
        if (platform != "aarch64-linux" || "x86_64-darwin")
        then [
          # inputs.flatpaks.homeManagerModules.default
          inputs.nur.hmModules.nur
          ../home-manager
        ]
        else [ ../home-manager ];
    };

  # Helper function for generating host configs
  mkHost =
    { hostname, username, desktop ? null, hostid ? null, platform ? "x86_64-linux", stateVersion ? "23.11" }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs desktop hostname username hostid stateVersion;
      };
      modules =
        let
          isISO = if (builtins.substring 0 4 hostname == "iso-") then true else false;
          cd-dvd = if (desktop == null) then inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" else inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
        in
        [
          ../nixos
          inputs.chaotic.nixosModules.default # DEFAULT MODULE
        ]
        ++ (inputs.nixpkgs.lib.optionals (isISO) [ cd-dvd ]);
    };

  systems = inputs.nixpkgs.lib.genAttrs [
    "x86_64-linux"
    "aarch64-linux"
    # "i686-linux"
    # "x86_64-darwin"
    # "aarch64-darwin"
  ];
}
