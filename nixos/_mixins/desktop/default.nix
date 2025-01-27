{ desktop, isInstall, lib, pkgs, config, hostname, ... }:
let
  inherit (lib) mkIf mkDefault optional optionals mkOptionDefault;
in
{
  imports = [
    ./apps
    ./features
  ] ++ optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop};

  config = {
    features = {
      bluetooth.enable = true;
      audio.manager = mkDefault "pipewire";
    };

    desktop = {
      features = {
        appimage.enable = true;
        fonts.enable = true;
        printers.enable = false;
        scan.enable = false;
        v4l2loopback.enable = false;
      };

      apps = {
        _1password.enable = false;
        blender.enable = false;
        games = mkDefault {
          enable = false;
          engines = [ null ];
        };
        graphics-production.enable = false;
      };
    };

    environment = {
      etc = {
        # Allow mounting FUSE filesystems as a user.
        # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
        "fuse.conf".text = "user_allow_other";
      };

      systemPackages = with pkgs;  [
        firefox
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
      ] ++ optionals isInstall [
        notify-desktop
        xdotool
        ydotool
      ] ++ optionals (config.features.graphics.backend == "x11") [ wmctrl ];

      sessionVariables = {
        "TMPDIR" = "/tmp";
      };
    };

    # programs.dconf.enable = true;

    services = {
      dbus.enable = true;

      usbmuxd.enable = true; # for IOS;

      xserver = {
        # Disable xterm
        desktopManager.xterm.enable = false;
        excludePackages = [ pkgs.xterm ];

        xkb =
          if (hostname == "nitro") || (hostname == "scrubber") then {
            layout = "br";
            variant = "abnt2";
            model = "pc105";
          }
          else {
            layout = "us";
            variant = "mac";
            model = "pc104";
          };
      };

      gvfs = {
        enable = mkOptionDefault true;
      };

      gnome.gnome-keyring =
        let
          desktops = desktop == "hyprland" || desktop == "mate" || desktop == "xfce4" || desktop == "budgie" || desktop == "bspwm" || desktop == "gnome";
        in
        {
          enable = mkIf desktops true;
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

    # Fix xdg-portals opening URLs: https://github.com/NixOS/nixpkgs/issues/189851
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };
}
