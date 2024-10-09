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
        fonts.enable = true;
        printers.enable = false;
        scan.enable = false;
        v4l2loopback.enable = false;
        xdg.enable = true;
      };
      games = {
        enable = false;
        engines = [ null ];
      };

      apps = {
        _1password.enable = true;
        blender.enable = false;
      };
    };

    environment.etc = {
      "backgrounds/Cat-1920px.png".source = ../configs/backgrounds/Cat-1920px.png;
      "backgrounds/Cat-2560px.png".source = ../configs/backgrounds/Cat-2560px.png;
      "backgrounds/Cat-3440px.png".source = ../configs/backgrounds/Cat-3440px.png;
      "backgrounds/Cat-3840px.png".source = ../configs/backgrounds/Cat-3840px.png;
      "backgrounds/Catppuccin-1920x1080.png".source = ../configs/backgrounds/Catppuccin-1920x1080.png;
      "backgrounds/Catppuccin-1920x1200.png".source = ../configs/backgrounds/Catppuccin-1920x1200.png;
      "backgrounds/Catppuccin-2560x1440.png".source = ../configs/backgrounds/Catppuccin-2560x1440.png;
      "backgrounds/Catppuccin-2560x1600.png".source = ../configs/backgrounds/Catppuccin-2560x1600.png;
      "backgrounds/Catppuccin-2560x2880.png".source = ../configs/backgrounds/Catppuccin-2560x2880.png;
      "backgrounds/Catppuccin-3440x1440.png".source = ../configs/backgrounds/Catppuccin-3440x1440.png;
      "backgrounds/Catppuccin-3840x2160.png".source = ../configs/backgrounds/Catppuccin-3840x2160.png;
      "backgrounds/Colorway-1920x1080.png".source = ../configs/backgrounds/Colorway-1920x1080.png;
      "backgrounds/Colorway-1920x1200.png".source = ../configs/backgrounds/Colorway-1920x1200.png;
      "backgrounds/Colorway-2560x1440.png".source = ../configs/backgrounds/Colorway-2560x1440.png;
      "backgrounds/Colorway-2560x1600.png".source = ../configs/backgrounds/Colorway-2560x1600.png;
      "backgrounds/Colorway-2560x2880.png".source = ../configs/backgrounds/Colorway-2560x2880.png;
      "backgrounds/Colorway-3440x1440.png".source = ../configs/backgrounds/Colorway-3440x1440.png;
      "backgrounds/Colorway-3840x2160.png".source = ../configs/backgrounds/Colorway-3840x2160.png;
    };

    environment.systemPackages =
      with pkgs;
      [
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
      ]
      ++ lib.optionals isInstall [
        notify-desktop
        wmctrl
        xdotool
        ydotool
      ];
    programs.dconf.enable = true;
    services = {
      dbus.enable = true;
      usbmuxd.enable = true;
      xserver = {
        # Disable xterm
        desktopManager.xterm.enable = false;
        excludePackages = [ pkgs.xterm ];
      };
    };
  };
}
