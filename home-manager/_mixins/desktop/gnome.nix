{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  home = {
    packages = with pkgs; [
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.user-themes
      gnomeExtensions.aylurs-widgets
      gnome.mutter
      gnomeExtensions.battery-indicator-upower
      gnome-extension-manager
      gnome.gnome-tweaks
      gnome.libgnome-keyring
      gnomeExtensions.forge
      gnomeExtensions.gsconnect # kdeconnect enabled in default.nix
      # gnomeExtensions.tray-icons-reloaded
      # gnomeExtensions.removable-drive-menu
      # gnomeExtensions.dash-to-panel
      # gnomeExtensions.battery-indicator-upower
      # gnomeExtensions.caffeine
      # gnomeExtensions.workspace-indicator-2
      # gnomeExtensions.bluetooth-quick-connect
      # gnomeExtensions.pip-on-top
      # gnomeExtensions.pop-shell
      # gnomeExtensions.fullscreen-avoider
      # gnomeExtensions.dash-to-dock

      gnome3.gvfs
      gnome3.nautilus
    ];

    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features
    sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
    };
  };
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.settings.desktop"
        # "alacritty.desktop"
        "firefox.desktop"
        # "emacs.desktop"
        "org.gnome.nautilus.desktop"
        # "com.obsproject.studio.desktop"
        # "plexmediaplayer.desktop"
        # "smartcode-stremio.desktop"
        # "discord.desktop"
        # "steam.desktop"
        # "retroarch.desktop"
        # "com.parsecgaming.parsec.desktop"
        # "org.remmina.remmina.desktop"
        "virt-manager.desktop"
        # "blueman-manager.desktop"
        # "pavucontrol.desktop"
      ];
      disable-user-extensions = false;
      enabled-extensions = [
        "just-perfection-desktop@just-perfection"
        "blur-my-shell@aunetx"
        "clipboard-indicator@tudmotu.com"
        "bluetooth-quick-connect@bjarosze.gmail.com"
        "gsconnect@andyholmes.github.io"
        "forge@jmmaranan.com"
        "battery-indicator-upower@malko"
        # "battery-indicator@jgotti.org"
        # "just-perfection@jrahmatzadeh"
        # "trayiconsreloaded@selfmade.pl"
        # "drive-menu@gnome-shell-extensions.gcampax.github.com"
        # "dash-to-panel@jderose9.github.com"
        # "caffeine@patapon.info"
        # "horizontal-workspace-indicator@tty2.io"
        # "pip-on-top@rafostar.github.com"
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-weekday = true;
      clock-format = "24h";
      clock-show-date = true;
      clock-show-seconds = true;
      gtk-theme = "adwaita-dark";
      cursor-blink = true;
      cursor-size = 24;
      cursor-theme = "Breeze_Hacked";
      enable-animations = true;
      enable-hot-corners = true;
      icon-theme = "Qogir-ubuntu-dark";
      show-battery-percentage = true;
      toolbar-icon-size = "small";
    };
    "org/gnome/desktop/media-handling" = {
      automount = true;
      automount-open = true;
    };
    "org/gnome/desktop/privacy" = {
      report-technical-problems = "false";
    };
    "org/gnome/calendar" = {
      active-view = "month";
    };
    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };
    "org/gnome/desktop/applications/terminal" = {
      exec = "tilix";
      exec-arg = "-x";
    };
    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };
    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
      center-new-windows = true;
      edge-tiling = true; # Tiling
    };
  };
}
