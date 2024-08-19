{ config, hostname, isInstall, isWorkstation, inputs, lib, modulesPath, outputs, pkgs, platform, stateVersion, username, nixpkgs, ... }:
with lib;
let
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  imports = [
    (./. ./hosts/${hostname})
    ../modules/nixos
    ./users
  ];

  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelModules = [ "vhost_vsock" ];
    kernelParams = [ "udev.log_priority=3" ];
    kernelPackages = pkgs.linuxPackages_latest;
    # Only enable the systemd-boot on installs, not live media (.ISO images)
    loader = mkIf isInstall {
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.consoleMode = "max";
      systemd-boot.enable = true;
      systemd-boot.memtest86.enable = true;
      timeout = 10;
    };
  };

  #determinate.nix.primaryUser.username = username;

  # Only install the docs I use
  documentation = {
    enable = true;
    nixos.enable = false;
    man.enable = true;
    info.enable = false;
    doc.enable = false;
  };

  environment = {
    # Eject nano and perl from the system
    defaultPackages =
      with pkgs;
      mkForce [
        coreutils-full
        micro
      ];

    systemPackages =
      with pkgs;
      [
        git
        nix-output-monitor
      ]
      ++ optionals isInstall [
        inputs.nixos-needtoreboot.packages.${platform}.default
        nvd
        nvme-cli
        smartmontools
        sops
      ];

    variables = {
      EDITOR = mkDefault "micro";
      SYSTEMD_EDITOR = mkDefault "micro";
      VISUAL = mkDefault "micro";
    };

    shellAliases = {
      nano = mkDefault "micro";
    };
  };

  programs = {
    command-not-found.enable = false;
    fish = {
      enable = true;
    };
    nano.enable = lib.mkDefault false;
    nh = {
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
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
      homepage-env = { };
    };
  };

  systemd.tmpfiles.rules = [ "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root" ];

  system = {
    nixos.label = lib.mkIf isInstall "-";
    inherit stateVersion;
  };
}
