{ inputs, outputs, stateVersion, ... }:

{
  # Helper function for generating home-manager configs
  mkHome =
    { hostname
    , username ? "juca"
    , desktop ? null
    , platform ? "x86_64-linux"
    ,
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isLima = hostname == "grozbok" || hostname == "zeta";
      isWorkstation = builtins.isString desktop;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          stateVersion
          isInstall
          isLima
          isISO
          isWorkstation
          ;
      };
      modules = [ ../home-manager ];
    };

  # Helper function for generating NixOS configs
  mkNixos =
    { hostname
    , username ? "juca"
    , desktop ? null
    , platform ? "x86_64-linux"
    , hostid ? null
    ,
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isWorkstation = builtins.isString desktop;
      notVM = if (hostname == "minimech") || (hostname == "scrubber") || (hostname == "vm") || (builtins.substring 0 5 hostname == "lima-") then false else true;
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          hostid
          stateVersion
          isInstall
          isISO
          isWorkstation
          notVM
          ;
      };
      # If the hostname starts with "iso-", generate an ISO image
      modules =
        let
          cd-dvd =
            if (desktop == null) then
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            else
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
        in
        [
          ../nixos

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          # inputs.home-manager.nixosModules.home-manager
          {
            # home-manager = {
            #   useGlobalPkgs = true;
            #   useUserPackages = true;

            #   # TODO replace juca with your own username
            #   users.juca = import ../home-manager;

            #   # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            #   extraSpecialArgs = { inherit (inputs.config.home-manager.homeManagerConfiguration.extraSpecialArgs) extraSpecialArgs; };
            # };
          }
        ]
        ++ inputs.nixpkgs.lib.optionals isISO [ cd-dvd ];
    };

  mkDarwin =
    { desktop ? "aqua"
    , hostname
    , username ? "juca"
    , platform ? "aarch64-darwin"
    ,
    }:
    let
      isISO = false;
      isInstall = true;
      isWorkstation = true;
    in
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          stateVersion
          isInstall
          isISO
          isWorkstation
          ;
      };
      modules = [ ../darwin ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs
    [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
}
