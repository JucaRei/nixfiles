{ inputs, outputs, pkgs, stateVersion, ... }: {
  # Helper function for generating home-manager configs

  makeHomeManager =
    { hostname
    , username ? "juca"
    , desktop ? null
    , platform ? "x86_64-linux"
    , stateVersion ? "23.05"
    , useNixGL ? false
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isWorkstation = builtins.isString desktop;

      notVM = if (hostname == "virtual") || (hostname == "virtualvm") || (hostname == "vm") || (hostname == "soyoz-vm") then false else true;
      pkgs = inputs.nixpkgs.legacyPackages.${platform}.extend inputs.nixgl.overlay;
      mkNixGL = import ./nixGL.nix { inherit pkgs; }; # Removed .wrapper
      nixGLWrapper = if useNixGL then mkNixGL else (x: x);
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion useNixGL isInstall isISO notVM isWorkstation nixGLWrapper;
      };
      modules = [ ../home-manager ];
    };

  makeNixOS =
    { hostname
    , username ? "juca"
    , desktop ? null
    , platform ? "x86_64-linux"
    , hostid ? null
    , stateVersion ? "23.05"
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isWorkstation = builtins.isString desktop;

      notVM = if (hostname == "virtual") || (hostname == "virtualvm") || (hostname == "vm") || (hostname == "soyoz-vm") then false else true;
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs desktop hostname hostid stateVersion isInstall isISO isWorkstation notVM
          platform username;
      };

      modules = [
        ../nixos

        #  make home-manager as a module of nixos
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            backupFileExtension = "hm.backup";
            users.${username} = import ../home-manager;
            extraSpecialArgs = {
              inherit inputs outputs desktop hostname platform username stateVersion isInstall isISO isWorkstation notVM;
            };
          };
        }
      ] ++
      inputs.nixpkgs.lib.optionals isISO [
        (if (desktop == null) then
          inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        else
          inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"
        )
      ];
    };

  # mkDarwin =
  #   { desktop ? "aqua"
  #   , hostname
  #   , username ? "juca"
  #   , platform ? "aarch64-darwin"
  #   ,
  #   }:
  #   let
  #     isISO = false;
  #     isInstall = true;
  #     isWorkstation = true;
  #   in
  #   inputs.nix-darwin.lib.darwinSystem {
  #     specialArgs = {
  #       inherit
  #         inputs
  #         outputs
  #         desktop
  #         hostname
  #         platform
  #         username
  #         stateVersion
  #         isInstall
  #         isISO
  #         isWorkstation
  #         ;
  #     };
  #     modules = [ ../darwin ];
  #   };

  # mkSystemManager = { system ? "x86_64-linux", }:
  #   inputs.system-manager.lib.makeSystemConfig {
  #     modules = [
  #       inputs.nix-system-graphics.systemModules.default
  #       {
  #         config = {
  #           nixpkgs.hostPlatform = system;
  #           system-manager.allowAnyDistro = true;
  #           system-graphics.enable = true;
  #         };
  #       }
  #     ];
  #   };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
