{ config, lib, pkgs, desktop, ... }:
let
  inherit (lib) optional mkOptionDefault;
in
{
  imports = [
    ../backend
    ../display-manager
    ../../apps
  ] ++ optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop};

  config = {

    system = {
      security = {
        keyring = {
          enable = true;
        };

        pam = {
          enable = true;
        };
      };

      services = {
        appimage = {
          enable = true;
        };
        samba = {
          enable = true;
        };
      };

      time = {
        enable = true;
        provider = mkOptionDefault [ "chrony" ];
      };
    };

    programs = {
      graphical = {
        apps = {
          _1password.enable = true;
        };
      };
    };

    services = {
      xserver = {
        desktopManager = {
          xterm.enable = mkOptionDefault false;
        };
        excludePackages = [ pkgs.xterm ];
      };

      gvfs = {
        enable = true;
        package = pkgs.gnome.gvfs;
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
          "mount_options.conf" = {
            defaults = {
              # ntfs_defaults = "uid=$UID,gid=$GID,noatime,prealloc";
              ntfs_defaults = "uid=$UID,gid=$GID,noatime";
            };
          };
        };
      };
    };

    environment = {
      etc = {
        # Allow mounting FUSE filesystems as a user.
        # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
        "fuse.conf".text = "user_allow_other";
      };

      systemPackages = with pkgs;  [
        # gsmartcontrol
        catppuccin-cursors.mochaBlue
        (catppuccin-gtk.override {
          accents = [ "blue" ];
          size = "standard";
          variant = "mocha";
        })
        (catppuccin-papirus-folders.override {
          flavor = "mocha";
          accent = "blue";
        })
      ];

      sessionVariables = {
        "TMPDIR" = "/tmp";
      };
    };

    # Fix xdg-portals opening URLs: https://github.com/NixOS/nixpkgs/issues/189851
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };
}
