{ desktop, isInstall, lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./apps
    ./features
  ] ++ lib.optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop};

  config = {
    desktop = {
      features = {
        appimage.enable = true;
        audio.manager = mkDefault "pipewire";
        bluetooth.enable = true;
        fonts.enable = true;
        printers.enable = false;
        scan.enable = false;
        v4l2loopback.enable = false;
        xdg.enable = true;
      };

      apps = {
        _1password.enable = true;
        blender.enable = false;
        games = mkDefault {
          enable = false;
          engines = [ null ];
        };
        graphics-production.enable = false;
        libreoffice.enable = isInstall;
      };
    };

    environment = {
      etc = {
        "backgrounds/Cat-1920px.png".source = ../../../resources/dots/backgrounds/Cat-1920px.png;
        "backgrounds/Cat-2560px.png".source = ../../../resources/dots/backgrounds/Cat-2560px.png;
        "backgrounds/Cat-3440px.png".source = ../../../resources/dots/backgrounds/Cat-3440px.png;
        "backgrounds/Cat-3840px.png".source = ../../../resources/dots/backgrounds/Cat-3840px.png;
        "backgrounds/Catppuccin-1920x1080.png".source = ../../../resources/dots/backgrounds/Catppuccin-1920x1080.png;
        "backgrounds/Catppuccin-1920x1200.png".source = ../../../resources/dots/backgrounds/Catppuccin-1920x1200.png;
        "backgrounds/Catppuccin-2560x1440.png".source = ../../../resources/dots/backgrounds/Catppuccin-2560x1440.png;
        "backgrounds/Catppuccin-2560x1600.png".source = ../../../resources/dots/backgrounds/Catppuccin-2560x1600.png;
        "backgrounds/Catppuccin-2560x2880.png".source = ../../../resources/dots/backgrounds/Catppuccin-2560x2880.png;
        "backgrounds/Catppuccin-3440x1440.png".source = ../../../resources/dots/backgrounds/Catppuccin-3440x1440.png;
        "backgrounds/Catppuccin-3840x2160.png".source = ../../../resources/dots/backgrounds/Catppuccin-3840x2160.png;
        "backgrounds/Colorway-1920x1080.png".source = ../../../resources/dots/backgrounds/Colorway-1920x1080.png;
        "backgrounds/Colorway-1920x1200.png".source = ../../../resources/dots/backgrounds/Colorway-1920x1200.png;
        "backgrounds/Colorway-2560x1440.png".source = ../../../resources/dots/backgrounds/Colorway-2560x1440.png;
        "backgrounds/Colorway-2560x1600.png".source = ../../../resources/dots/backgrounds/Colorway-2560x1600.png;
        "backgrounds/Colorway-2560x2880.png".source = ../../../resources/dots/backgrounds/Colorway-2560x2880.png;
        "backgrounds/Colorway-3440x1440.png".source = ../../../resources/dots/backgrounds/Colorway-3440x1440.png;
        "backgrounds/Colorway-3840x2160.png".source = ../../../resources/dots/backgrounds/Colorway-3840x2160.png;

        # Allow mounting FUSE filesystems as a user.
        # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
        "fuse.conf".text = "user_allow_other";
      };

      systemPackages = with pkgs; [
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
      ] ++ lib.optionals isInstall [
        notify-desktop
        wmctrl
        xdotool
        ydotool
      ];
    };
    programs.dconf.enable = true;
    services = {
      dbus.enable = true;
      usbmuxd.enable = true; # for IOS;
      xserver = {
        # Disable xterm
        desktopManager.xterm.enable = false;
        excludePackages = [ pkgs.xterm ];
      };
      samba = {
        enable = true;
        #package = pkgs.unstable.samba4Full; # samba4Full broken
        # securityType = "user";
        # openFirewall = true;
        extraConfig = ''
          # My old nas dlink-325 uses v1
          client min protocol = NT1
        '';
      };
      gvfs = {
        package = pkgs.unstable.gvfs;
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
          "mount_options.conf" = {
            defaults = {
              # ntfs_defaults = "uid=$UID,gid=$GID,noatime,prealloc";
              ntfs_defaults = "uid=$UID,gid=$GID,noatime";
            };
          };
        };
      };
    };
  };
}
