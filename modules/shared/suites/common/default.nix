{ config, lib, pkgs, namespace, ... }:
let
  inherit (lib) mkIf mkForce;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.suites.common;
  username = config.${namespace}.user.name;
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
    };

    systemd = {
      tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash" # Create symlink to /bin/bash
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root" # Create dirs for home-manager
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
    };

    system = {
      switch = {
        # enable = true; # false; # Perl
        enableNg = true; # Rust-based re-implementation of the original Perl switch-to-configuration
      };
    };
  };
}
