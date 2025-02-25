{ config, lib, username, pkgs, isWorkstation, ... }:
let
  inherit (lib) mkOption mkIf mkForce mkOverride;
  inherit (lib.types) bool;
  cfg = config.roles.server;
in
{
  options = {
    roles.server = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable server role's";
      };
    };
  };

  config = mkIf cfg.enable {

    roles.common = {
      enable = true;
    };

    system = {
      optimizations = {
        enable = true;
      };
    };

    hardware = {
      cpu = {
        hardenKernel = mkOverride 900 true;
        improveTCP = mkOverride 900 true;
        enableKvm = mkOverride 900 false;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        cachix
      ];
    };

    programs = {
      nix-index-database = {
        comma.enable = true;
      };
    };

    services = {
      xserver = {
        enable = mkForce false;
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root" # Create dirs for home-manager
        "d /var/lib/private/sops/age 0755 root root"
      ];

      services = {
        "user@".serviceConfig.Delegate = false;
        systemd-user-sessions.enable = false;
      };

      targets = {
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };
    };
  };
}
