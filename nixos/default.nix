{ config, hostname, isInstall, isWorkstation, inputs, lib, modulesPath, outputs, pkgs, platform, stateVersion, username, ... }:
let
  inherit (lib) mkIf mkDefault optional;
in
{
  imports = [
    inputs.auto-cpufreq.nixosModules.default
    inputs.catppuccin.nixosModules.catppuccin
    inputs.determinate.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-snapd.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    (modulesPath + "/installer/scan/not-detected.nix")
    ./${hostname}
    ./_mixins/configs
    ./_mixins/core
    ./_mixins/features
    ./_mixins/scripts
    ./_mixins/services
    ./_mixins/users
  ] ++ optional isWorkstation ./_mixins/desktop;

  config = {
    ######################
    ### Custom Modules ###
    ######################
    core = {
      # Default boot Options
      boot = {
        enable = mkDefault isInstall;
        boottype = mkDefault "efi";
        bootmanager = mkDefault "systemd-boot";
        isDualBoot = mkDefault false;
        secureBoot = mkDefault false;
        silentBoot = mkDefault isWorkstation;
        plymouth = mkDefault isWorkstation;
      };

      # Selected default docs
      documentation = {
        enable = mkDefault true;
        doctypes = [ "man" ];
      };
    };

    environment = {
      # Eject nano and perl from the system
      defaultPackages =
        with pkgs;
        lib.mkForce [
          coreutils-full
          micro
        ];

      systemPackages =
        with pkgs;
        [
          git
          nix-output-monitor
        ]
        ++ lib.optionals isInstall [
          inputs.determinate.packages.${platform}.default
          inputs.nixos-needtoreboot.packages.${platform}.default
          nvd
          nvme-cli
          smartmontools
          sops
        ];

      variables = {
        EDITOR = "micro";
        SYSTEMD_EDITOR = "micro";
        VISUAL = "micro";
      };
    };

    nixpkgs = {
      # You can add overlays here
      overlays = [
        # Add overlays your own flake exports (from overlays and pkgs dir):
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        # Add overlays exported from other flakes:
      ];
      # Configure your nixpkgs instance
      config = {
        allowUnfree = true;
      };
    };

    nix =
      let
        flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
      in
      {
        settings = {
          experimental-features = "flakes nix-command";
          # Disable global registry
          flake-registry = "";
          # Workaround for https://github.com/NixOS/nix/issues/9574
          nix-path = config.nix.nixPath;
          trusted-users = [
            "root"
            "${username}"
          ];
          warn-dirty = false;
        };
        # Disable channels
        channel.enable = false;
        # Make flake registry and nix path match flake inputs
        registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
        nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
      };

    nixpkgs.hostPlatform = lib.mkDefault "${platform}";

    programs = {
      command-not-found.enable = false;
      fish = {
        enable = true;
        shellAliases = {
          nano = "micro";
        };
      };
      nano.enable = lib.mkDefault false;
      nh = {
        clean = {
          enable = true;
          extraArgs = "--keep-since 15d --keep 10";
        };
        enable = true;
        flake = "/home/${username}/Zero/nix-config";
      };
      nix-index-database.comma.enable = isInstall;
      nix-ld = lib.mkIf isInstall {
        enable = true;
        libraries = with pkgs; [
          # Add any missing dynamic libraries for unpackaged
          # programs here, NOT in environment.systemPackages
        ];
      };
    };

    services = {
      fwupd.enable = isInstall;
      hardware.bolt.enable = true;
      smartd.enable = isInstall;
    };

    sops = lib.mkIf (isInstall && username == "juca") {
      age = {
        keyFile = "/home/${username}/.config/sops/age/keys.txt";
        generateKey = false;
      };
      defaultSopsFile = ../secrets/secrets.yaml;
      # sops-nix options: https://dl.thalheim.io/
      secrets = {
        test-key = { };
      };
    };

    systemd.tmpfiles.rules = [ "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root" ];

    system = {
      nixos.label = lib.mkIf isInstall "-";
      inherit stateVersion;
    };
  };
}
