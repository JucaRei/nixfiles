{ config, lib, pkgs, namespace, ... }:
let
  inherit (lib) mkIf mkForce;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.suites.common;
  username = config.${namespace}.user.name;
  server = config.${namespace}.archetypes.server;
in
{
  options.${namespace}.suites.common = {
    enable = mkBoolOpt false "Whether or not to enable common configuration.";
  };

  config = mkIf cfg.enable {
    environment = {
      # Eject nano and perl from the system
      defaultPackages = with pkgs; mkForce [
        uutils-coreutils-noprefix
        parted
        micro
        wget
        killall
      ];

      systemPackages = with pkgs; [
        curl
        fd
        file
        findutils
        lsof
        pciutils
        tldr
        unzip
        xclip
      ];

      shellAliases = {
        nix_package_size = "nix path-info --size --human-readable --recursive /run/current-system | cut -d - -f 2- | sort";
        store-path = "${pkgs.uutils-coreutils-noprefix}/bin/readlink (${pkgs.which}/bin/which $argv)";
        keyring-lock = ''${pkgs.systemdMinimal}/bin/busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked'';
      };

      ## Create a file in /etc/installed/nixos-current-system-packages  Listing all Packages ###
      etc = {
        "nixos-current-system-packages" = {
          text =
            let
              packages =
                builtins.map (p: "${p.name}") config.environment.systemPackages;
              sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
              formatted = builtins.concatStringsSep "\n" sortedUnique;
            in
            formatted;
        };
      };
    };

    systemd = {
      tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash" # Create symlink to /bin/bash
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root" # Create dirs for home-manager
        "d /var/lib/private/sops/age 0755 root root"
      ];

      extraConfig = ''
        # DefaultTimeoutStartSec=s
        DefaultTimeoutStopSec=10s
        # DefaultDeviceTimeoutSec=8s
        # DefaultTimeoutAbortSec=10s

        DefaultCPUAccounting=yes
        DefaultMemoryAccounting=yes
        DefaultIOAccounting=yes
      '';

      services = {
        "user@".serviceConfig.Delegate = true;

        nix-gc = {
          unitConfig.ConditionACPower = true; ### Nix gc when powered
        };

        nix-daemon.serviceConfig = {
          CPUWeight = 20;
          IOWeight = 20;
        };

        NetworkManager-wait-online.enable = mkForce false;
        systemd-udev-settle.enable = mkForce false;
      };

      targets = mkIf server {
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };
    };

    system = {
      switch = {
        # enable = true; # false; # Perl
        enableNg = true; # Rust-based re-implementation of the original Perl switch-to-configuration
      };
    };
  };
}
