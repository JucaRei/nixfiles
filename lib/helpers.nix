{ inputs, outputs, stateVersion, ... }:
{
  # Helper function for generating home-manager configs
  makeHome =
    { hostname
    , username ? "juca"
    , desktop ? null
    , hostid ? null
    , platform ? "x86_64-linux"
    , stateVersion ? "24.05"
    ,
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isLima = builtins.substring 0 5 hostname == "lima-";
      isWorkstation = builtins.isString desktop;
      notVM = if (hostname == "minimech") || (hostname == "scrubber") || (hostname == "vm") || (builtins.substring 0 5 hostname == "lima-") then false else true;
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
          hostid
          username
          stateVersion
          isInstall
          isLima
          isISO
          isWorkstation
          notVM
          ;
      };
      modules = [ ../modules/home-manager/linux ];
    };

  # Helper function for generating NixOS configs
  makeSystem =
    { hostname
    , username ? "juca"
    , desktop ? null
    , platform ? "x86_64-linux"
    , stateVersion ? "24.05"
    ,
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isLima = builtins.substring 0 5 hostname == "lima-";
      isWorkstation = builtins.isString desktop;
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
          stateVersion
          isInstall
          isLima
          isISO
          isWorkstation
          ;
      };
      # If the hostname starts with "iso-", generate an ISO image
      modules =
        let
          cd-dvd =
            if (desktop == null) then
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                { isoImage.squashfsCompression = "gzip -Xcompression-level 1"; }
            else
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"
                { isoImage.squashfsCompression = "gzip -Xcompression-level 1"; };
        in
        [ ../modules/system ] ++ inputs.nixpkgs.lib.optionals isISO [ cd-dvd ];
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
      isLima = false;
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
          isLima
          isISO
          isWorkstation
          ;
      };
      modules = [ ../modules/home-manager/darwin ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
