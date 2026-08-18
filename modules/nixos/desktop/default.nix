{ lib, pkgs, desktop, ... }:
let
  inherit (lib) mkOptionDefault mkDefault;
in
{
  imports = [
    ./display-servers
    ./display-managers
  ]
  ++ lib.optionals (desktop != null && builtins.pathExists (./. + "/environments/${desktop}")) [
    (./. + "/environments/${desktop}")
  ]
  ;

  config = {
    environment = {
      etc = {
        # Allow mounting FUSE filesystems as a user.
        # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
        "fuse.conf".text = "user_allow_other";
      };

      localBinInPath = true;
    };

    services = {
      irqbalance = {
        enable = true;
      };
      gvfs = {
        enable = true;
        package = pkgs.gvfs;
      };
      usbmuxd = {
        enable = true;
      };
      udisks2 = {
        enable = true;
        mountOnMedia = true;
        settings = {
          "media-automount.conf" = {
            defaults = {
              mount_defaults = ''
                ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /media"
              '';
            };
          };
          # fix NTFS mount, from https://wiki.archlinux.org/title/NTFS#udisks_support
          # "mount_options.conf" = {
          #   defaults = {
          #     # ntfs_defaults = "uid=$UID,gid=$GID,noatime,prealloc";
          #     ntfs_defaults = "uid=$UID,gid=$GID,noatime";
          #   };
          # };
        };
      };
    };

    fonts = {
      enableDefaultPackages = false;
      fontDir = {
        enable = mkDefault true;
        # decompressFonts = false;
      };
      packages = with pkgs.nerd-fonts; [
        fira-code
      ];
      fontconfig = {
        antialias = true;
        defaultFonts = {
          serif = [ ];
          sansSerif = [ ];
          monospace = [ "FiraCode Nerd Font Mono" ];
        };
        enable = true;
        hinting = {
          autohint = false;
          enable = true;
          style = "slight";
        };
        subpixel = {
          rgba = "rgb";
          lcdfilter = "light";
        };
      };
    };

    hardware.cpu = {
      enable = mkOptionDefault true;
      improveTCP = mkOptionDefault true;
    };

    location = {
      provider = "geoclue2";
    };

    systemd = {
      services = {
        fixSuspend = {
          enable = true;
          description = "Fix immediate wakeup on suspend/hibernate";
          serviceConfig = {
            User = "root";
            ExecStart = "-${pkgs.bash}/bin/bash -c \"echo GPP0 > /proc/acpi/wakeup\"";
          };
          wantedBy = [ "multi-user.target" ];
        };
      };

      # Fix xdg-portals opening URLs: https://github.com/NixOS/nixpkgs/issues/189851
      user = {
        extraConfig = ''
          DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        '';
      };
    };
  };
}
