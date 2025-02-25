{ config, lib, username, pkgs, isWorkstation, ... }:
let
  inherit (lib) mkOption mkIf mkForce mkOverride;
  inherit (lib.types) bool;
  cfg = config.roles.workstation;
in
{
  options = {
    roles.workstation = {
      enable = mkOption {
        type = bool;
        default = isWorkstation;
        description = "Enable workstation role's";
      };
    };
  };

  config = mkIf cfg.enable {
    roles.common = {
      enable = true;
    };

    system = {
      console.enable = true;

      fonts = {
        enable = true;
      };

      optimizations = {
        enable = true;
      };
    };

    hardware = {
      audio = {
        enable = true;
        manager = "pipewire";
      };
      bluetooths = {
        enable = true;
      };
      cpu = {
        hardenKernel = mkOverride 900 true;
        improveTCP = mkOverride 900 true;
        enableKvm = mkOverride 900 true;
      };
      storage = {
        enable = true;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        nvd
        cachix
        sops
      ];
    };

    programs = {
      nix-index-database = {
        comma.enable = true;
      };
    };

    # sops = lib.mkIf (isInstall && username == "teste") {
    #   age = {
    #     keyFile = "/home/${username}/.config/sops/age/keys.txt";
    #     generateKey = false;
    #   };
    #   defaultSopsFile = ../secrets/secrets.yaml;
    #   # sops-nix options: https://dl.thalheim.io/
    #   secrets = {
    #     test-key = { };
    #   };
    # };

    systemd = {
      tmpfiles.rules = [
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root" # Create dirs for home-manager
        "d /var/lib/private/sops/age 0755 root root"
        "d /var/log/nix 0755 ${username} users"
      ];

      services = {
        "user@".serviceConfig.Delegate = true;
        systemd-user-sessions.enable = false;


        # https://github.com/NotAShelf/nyx/blob/d407b4d6e5ab7f60350af61a3d73a62a5e9ac660/modules/core/common/system/nix/module.nix#L236-L244
        nix-gc = {
          unitConfig.ConditionACPower = true; ### Nix gc when powered
        };
      };

      # targets = mkIf (hostname == "soyo") {
      #   hibernate.enable = false;
      #   hybrid-sleep.enable = false;
      # };
    };
  };
}
