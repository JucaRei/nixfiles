{ config, lib, isInstall, hostname, username, stateVersion, isWorkstation, pkgs, ... }:
let
  inherit (lib) mkForce mkIf mkDefault mkOption mkEnableOption types optional;
  cfg = config.sys.tweaks;
in
{
  options.sys.tweaks = {
    enable = mkEnableOption "Default system tweaks configuration." // { default = true; };
  };

  config = mkIf cfg.enable {
    ##############
    ### Tweaks ###
    ##############
    system = {
      nixos = {
        label = mkIf (isInstall) (builtins.concatStringsSep "-" [ "${hostname}-" ] + config.system.nixos.version);
        tags = mkIf (isInstall) [ "NixOS" ];
      };
      stateVersion = stateVersion;
    };

    systemd = {
      tmpfiles.rules = [
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
      ];

      user.extraConfig = ''
        DefaultCPUAccounting=yes
        DefaultMemoryAccounting=yes
        DefaultIOAccounting=yes
      '';

      extraConfig = ''
        DefaultTimeoutStartSec=8s
        DefaultTimeoutStopSec=10s
        DefaultDeviceTimeoutSec=8s
        DefaultTimeoutAbortSec=10s

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

        systemd-udev-settle.enable = lib.mkForce false;
      };

      targets = lib.mkIf (hostname == "soyo") {
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };

      # enable cgroups=v2 as default
      enableUnifiedCgroupHierarchy = mkForce isInstall;
    };
    services = {
      fwupd = {
        enable = isInstall;
      };

      dbus = {
        # packages = optional isWorkstation [ pkgs.gnome-keyring pkgs.gcr ];
        implementation = if isWorkstation then "broker" else "dbus";
      };
    };
  };
}
