{ inputs, outputs, ... }:

let
  inherit (inputs.nixpkgs) lib;
in
{

  # Helper function for generating standalone Home Manager configurations (for non-NixOS distros)
  mkHome =
    { hostname
    , username ? "juca"
    , desktop ? null
    , platform ? "x86_64-linux"
    , stateVersion ? "24.11"
    , useNixGL ? false
    , isISO ? false
    }:
    let
      isInstall = !isISO;
      isWorkstation = desktop != null;

      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      nixGLWrapper =
        if useNixGL then
          (import ./nixGL.nix { inherit pkgs; }).wrapper
        else
          (x: x);
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          stateVersion
          useNixGL
          isInstall
          isISO
          isWorkstation
          nixGLWrapper
          ;
      };
      modules = [
        ../home-manager
      ];
    };

  # Helper function for generating NixOS system configurations (with integrated Home Manager)
  mkNixos =
    { hostname
    , username ? "juca"
    , desktop ? null
    , platform ? "x86_64-linux"
    , hostid ? null
    , stateVersion ? "24.11"
    , isISO ? lib.hasPrefix "iso-" hostname
    , isVM ? false
    }:
    let
      isInstall = !isISO;
      isWorkstation = desktop != null;
      notVM = !isVM;
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
      modules =
        [
          ../nixos

          # Automatically deploy Home Manager configuration during nixos-rebuild switch
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = false;
              useUserPackages = true;
              backupFileExtension = "hm.backup";
              users.${username} = import ../home-manager;
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
                  isISO
                  isWorkstation
                  ;
                useNixGL = false;
                nixGLWrapper = (pkg: pkg);
              };
            };
          }
        ]
        ++ inputs.nixpkgs.lib.optionals isISO [
          (if desktop == null then
            inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          else
            inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix")
        ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  # Helper function to generate automated checks for nix flake check
  mkChecks = { self, inputs }:
    inputs.nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ] (_system: { });
}


