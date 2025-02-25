{ config, lib, isInstall, isWorkstation, username, pkgs, ... }:
let
  inherit (lib) mkOption mkForce mkIf mkOptionDefault mkDefault;
  inherit (lib.types) bool;
  cfg = config.roles.common;
in
{
  options = {
    roles.common = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable common role's";
      };
    };
  };

  config = mkIf cfg.enable {
    system = {
      boot = {
        enable = isInstall;
        boottype = mkDefault "efi";
        bootmanager = mkDefault "grub";
        isDualBoot = mkOptionDefault false;
        secureBoot = mkOptionDefault false;
        silentBoot = mkOptionDefault isWorkstation;
        plymouth = mkOptionDefault isWorkstation;
      };

      locales.enable = true;

      security = {
        superuser = {
          enable = mkDefault true;
          manager = mkDefault "sudo";
        };
      };

      docs = {
        enable = mkDefault true;
        doctypes = [ "man" ];
      };

      services = {
        ssh.enable = true;
      };

      scripts = {
        enable = true;
      };

    };

    hardware = {
      cpu = {
        enable = true;
        hardenKernel = false;
        improveTCP = false;
        enableKvm = false;
        cpuVendor = "intel";
      };

      network = {
        enable = true;
        networkOpt = mkDefault "network-manager";
        exclusive-locallan = mkDefault false;
        powersave = mkDefault false;
        wakeonlan = mkDefault false;
        custom-interface = mkOptionDefault "";
      };
    };

    environment = {
      # Eject nano and perl from the system
      defaultPackages = with pkgs; mkForce [
        uutils-coreutils-noprefix
        parted
        micro
      ];

      variables = {
        EDITOR = "micro";
        SYSTEMD_EDITOR = "micro";
        VISUAL = "micro";
      };

      shellAliases = {
        nix_package_size = "nix path-info --size --human-readable --recursive /run/current-system | cut -d - -f 2- | sort";
        store-path = "${pkgs.uutils-coreutils-noprefix}/bin/readlink (${pkgs.which}/bin/which $argv)";
        keyring-lock = "${pkgs.systemdMinimal}/bin/busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked";
      };

      systemPackages = with pkgs; [
        git
      ];

      ## Create a file in /etc/nixos-current-system-packages  Listing all Packages ###
      etc = {
        "nixos-current-system-packages" = {
          text =
            let
              packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
              sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
              formatted = builtins.concatStringsSep "\n" sortedUnique;
            in
            formatted;
        };
      };
    };

    programs = {
      command-not-found.enable = false;
      fish = {
        enable = true;
        shellAliases = {
          nano = "micro";
        };
      };
      nano = import ../../../../resources/nixos/scripts/nano.nix { inherit pkgs config lib; };

      nh = {
        clean = {
          enable = true;
          extraArgs = "--keep-since 5d --keep 7";
        };
        enable = true;
        flake = "/home/${username}/.dotfiles/nixfiles";
      };
    };

    systemd = {
      tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash" # Create symlink to /bin/bash
      ];

      user.extraConfig = ''
        DefaultCPUAccounting=yes
        DefaultMemoryAccounting=yes
        DefaultIOAccounting=yes
      '';

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

        nix-daemon.serviceConfig = {
          CPUWeight = 20;
          IOWeight = 20;
        };

        systemd-udev-settle.enable = mkForce false;
      };
    };
  };
}
