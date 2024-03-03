{ inputs
, outputs
, stateVersion
, ...
}: {
  # Helper function for generating home-manager configs
  mkHome =
    ### TODO - add displays
    { hostname
    , username
    , desktop ? null
    , stateVersion ? "23.11"
    , platform ? "x86_64-linux"
    ,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion;
      };
      modules =
        if platform != "aarch64-linux" || "aarch64-darwin"
        then [
          inputs.flatpaks.homeManagerModules.default
          inputs.nur.hmModules.nur
          ../home-manager
        ]
        else [ ../home-manager ];
    };

  # Helper function for generating host configs
  mkHost =
    { hostname
    , username
    , desktop ? null
    , hostid ? null
    , installer ? null
    , stateVersion ? "23.11"
      # , isNixOS ? true
    ,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs desktop hostname username hostid stateVersion;
      };
      modules =
        # if isNixOS
        # then
        #   [
        #     ../nixos
        #     inputs.home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       # (import ../home-manager)
        #     }
        #   ]
        #   ++ (inputs.nixpkgs.lib.optionals (installer != null) [ installer ])
        # else
        [ ../nixos ]
        ++ (inputs.nixpkgs.lib.optionals (installer != null) [ installer ]);
    };

  systems = inputs.nixpkgs.lib.genAttrs [
    # "i686-linux"
    "x86_64-linux"
    # "x86_64-darwin"
    "aarch64-linux"
    # "aarch64-darwin"
  ];
}
