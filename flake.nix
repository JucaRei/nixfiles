{
  description = "EXcalibur's NixOS configuration";

  inputs = {
    # NixPkgs
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2411.*";

    # NixPkgs Unstable
    # unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";

    oldstable.url = "https://flakehub.com/f/nixos/nixpkgs/0.2305.*";

    # Declarative disk management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Remote installation support
    nixos-anywhere.url = "github:numtide/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
    nixos-anywhere.inputs.disko.follows = "disko";

    # Nix user repository
    nur.url = "github:nix-community/NUR";

    snowfall-flake.url = "github:snowfallorg/flake";

    # Lix
    # lix = {
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # SOPS (secrets)
    sops-nix.url = "github:mic92/sops-nix";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # macOS Support
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware Configuration
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Secure boot
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.2";

    nix-index-database.url = "github:nix-community/nix-index-database";

    # Generate System Images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Bleeding edge packages (linux-cachyos)
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Impermanence
    impermanence.url = "github:nix-community/impermanence";

    # Snowfall Lib
    snowfall-lib.url = "github:snowfallorg/lib";
    # snowfall-lib.url = "path:/home/short/work/@snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    # Snowfall Flake
    flake.url = "github:snowfallorg/flake";
    flake.inputs.nixpkgs.follows = "unstable";

    # Snowfall Drift
    drift.url = "github:snowfallorg/drift";
    drift.inputs.nixpkgs.follows = "nixpkgs";

    # OpenGL wrapper for nix
    nixgl.url = "github:nix-community/nixGL";

    # Comma
    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "unstable";

    # System Deployment
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    # Run unpatched dynamically compiled binaries
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "unstable";

    # Binary Cache
    attic = {
      url = "github:zhaofengli/attic";

      # FIXME: A specific version of Rust is needed right now or
      # the build fails. Re-enable this after some time has passed.
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

  };

  outputs = inputs:
    let
      inherit (inputs) snowfall-lib;

      lib = snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        snowfall = {
          meta = {
            name = "EXcalibur";
            title = "EXnix Configs.";
          };

          namespace = "excalibur";
        };
      };
    in
    lib.mkFlake
      {
        channels-config = {
          allowUnfree = true;
          # allowBroken = true;
          # showDerivationWarnings = [ "maintainerless" ];
          permittedInsecurePackages = [
            "electron-25.9.0"
            "electron-27.3.11"
          ];
          allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
        };

        overlays = with inputs; [
          nixgl.overlay
          nur.overlays.default
          flake.overlays.default
          drift.overlays.default
          attic.overlays.default
          # lix.overlays.default
        ];

        homes = {
          modules = with inputs; [
            sops-nix.homeManagerModules.sops
            nur.modules.homeManager.default
            nix-index-database.hmModules.nix-index
          ];
        };

        systems = {
          modules = {
            darwin = with inputs;[
              sops-nix.darwinModules.sops
            ];
            nixos = with inputs; [
              home-manager.nixosModules.home-manager
              nix-ld.nixosModules.nix-ld
              disko.nixosModules.disko
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops
              chaotic.nixosModules.default
              {
                # manually import overlay
                chaotic.nyx.overlay.enable = false;
              }
              # lix.nixosModules.default
              # {
              #   system.tools.nixos-option.enable = false;
              # }
              # TODO: Replace excalibur.services.attic now that vault-agent
              # exists and can force override environment files.
              # attic.nixosModules.atticd
            ];
            hosts = {
              jasper = {
                modules = with inputs; [
                  nixos-hardware.nixosModules.framework-11th-gen-intel
                ];
                specialArgs = { };
              };
              juca = { };
            };
          };
        };

        deploy = lib.mkDeploy { inherit (inputs) self; };

        templates = { };

        checks = builtins.mapAttrs (system: deploy-lib: deploy-lib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;

        # outputs-builder = channels: { formatter = channels.nixpkgs.nixfmt-rfc-style ./shells/default/default.nix; };
        outputs-builder = channels: { formatter = channels.nixpkgs.nixfmt-rfc-style; };
      }
    // {
      self = inputs.self;
    }
  ;
}
