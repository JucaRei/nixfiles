{ config, lib, pkgs, namespace, ... }:
let
  inherit (lib) mkOptionDefault mkDefault mkIf;
  inherit (lib.${namespace}) mkBoolOpt enabled;
  cfg = config.${namespace}.suites.common;
  username = config.${namespace}.user.name;
  server = config.${namespace}.archetypes.server;
in
{
  imports = [ (lib.snowfall.fs.get-file "modules/shared/suites/common/default.nix") ];

  options.${namespace}.suites.common = {
    enable = mkBoolOpt false "Whether or not to enable common configuration.";
  };

  config = mkIf cfg.enable {
    environment = {
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
      ]
      ++
      (with pkgs.${namespace}; [
        list-iommu
        trace-symlink
        trace-which
      ])
      ;

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

      shellAliases = {
        nix_package_size = "nix path-info --size --human-readable --recursive /run/current-system | cut -d - -f 2- | sort";
        store-path = "${pkgs.uutils-coreutils-noprefix}/bin/readlink (${pkgs.which}/bin/which $argv)";
        keyring-lock = ''${pkgs.systemdMinimal}/bin/busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked'';
      };
    };

    ${namespace} = {
      nix = enabled;

      # TODO: Enable this once Attic is configured again.
      # cache.public = enabled;

      programs = {
        graphical = { };

        terminal = {
          apps = {
            flake = enabled;
            # thaw = enabled;
            comma = enabled;
          };

          tools = {
            git = enabled;
            misc = enabled;
            nix-ld = enabled;
            # bottom = enabled;
          };
        };
      };


      hardware = {
        audio = enabled;
        storage = enabled;
        networking = {
          enable = true;
          manager = "network-manager";
        };

        power = mkDefault enabled;
      };

      services = {
        # printing = enabled;
        ssh = enabled;
        # tailscale = enabled;
      };

      system = {
        boot = {
          enable = true;
          boottype = mkOptionDefault "efi";
          bootmanager = mkOptionDefault "grub";
          isDualBoot = mkOptionDefault false;
          secureBoot = mkOptionDefault false;
          silentBoot = mkOptionDefault false;
          plymouth = mkOptionDefault false;
        };
        fonts = enabled;
        locale = enabled;
        time = enabled;

        security = {
          # gpg = enabled;
          superuser = {
            enable = true;
            manager = mkDefault "sudo";
          };
        };
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d /var/lib/private/sops/age 0755 root root"
      ];

      targets = mkIf server {
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };
    };
  };
}
