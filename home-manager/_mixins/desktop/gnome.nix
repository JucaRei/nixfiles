{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  home = {
    packages = with pkgs; [
      gnomeExtensions.logo-menu
      # gnomeExtensions.aylurs-widgets
      gnomeExtensions.rounded-window-corners
      gnomeExtensions.appindicator
      # gnomeExtensions.google-earth-wallpaper
      gnomeExtensions.vitals
      # gnomeExtensions.pop-shell
      gnomeExtensions.space-bar
      gnomeExtensions.top-bar-organizer
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      # gnomeExtensions.clipboard-indicator
      # gnomeExtensions.user-themes
      # gnomeExtensions.hide-activities-button
      gnomeExtensions.caffeine
      # gnome.mutter
      gnomeExtensions.bluetooth-quick-connect
      gnome-extension-manager
      # gnome.libgnome-keyring
      gnomeExtensions.forge
      # gnomeExtensions.gsconnect # kdeconnect enabled in default.nix
      gnomeExtensions.dash-to-dock
      gnomeExtensions.pano
      # gnomeExtensions.arcmenu
      # gnomeExtensions.battery-indicator-upower
      # gnomeExtensions.tray-icons-reloaded
      gnome.gnome-weather
      deepin.deepin-gtk-theme
      # gnomeExtensions.removable-drive-menu
      # gnomeExtensions.dash-to-panel
      # gnomeExtensions.battery-indicator-upower
      # gnomeExtensions.workspace-indicator-2
      # gnomeExtensions.pip-on-top
      # gnomeExtensions.fullscreen-avoider
      layan-gtk-theme
      catppuccin-gtk

      gnome3.gvfs
      gnome3.nautilus

      # Others
      gaphor
      warp
      curtail
    ];
    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features
    sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
      # GTK_THEME = "palenight";
      # GTK_THEME = "WhiteSur-light-solid-pink";

    };
  };

  # GTK Configuration
  gtk = {
    enable = true;
    # font = {
    #   package = pkgs.fira;
    #   name = "Fira 10";
    # };
    theme = lib.mkDefault {
      # package = pkgs.whitesur-gtk-theme;
      # name = "WhiteSur-light-solid-pink";
      # package = pkgs.layan-gtk-theme;
      # name = "Layan-dark";
      name = "palenight";
      package = pkgs.palenight-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = "gtk-application-prefer-dark-theme = 1";
    };
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  # Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file://${../config/wallpapers/nix-asci.png}";
    };

    "org/blueman/plugins/powermanager" = {
      auto-power-on = "@mb true";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "stretched";
      picture-uri-dark = "file://${../config/wallpapers/nix-asci.png}";
      primary-color = "#ac5e0b";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/interface" = {
      clock-show-seconds = true;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      cursor-theme = "Breeze_Hacked";
      document-font-name = "FiraGO Medium 11";
      enable-animations = true;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      font-name = "Inter 10";
      gtk-enable-primary-paste = false;
      locate-pointer = true;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/notifications/application/code-url-handler" = {
      application-id = "code-url-handler.desktop";
    };

    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };

    "org/gnome/desktop/notifications/application/codium" = {
      application-id = "codium.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-fileroller" = {
      application-id = "org.gnome.FileRoller.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-software" = {
      application-id = "org.gnome.Software.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
      application-id = "org.gnome.tweaks.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
      left-handed = false;
      natural-scroll = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = false;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "stretched";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/truchet-l.webp";
      primary-color = "#ac5e0b";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<super>q" "<alt>f4" ];
      maximize = [ "@as []" ];
      move-to-monitor-left = [ "<super>left" ];
      move-to-monitor-right = [ "<super>right" ];
      move-to-workspace-1 = [ "<shift><alt>1" ];
      move-to-workspace-2 = [ "<shift><alt>2" ];
      move-to-workspace-3 = [ "<shift><alt>3" ];
      move-to-workspace-4 = [ "<shift><alt>4" ];
      move-to-workspace-5 = [ "<shift><alt>5" ];
      move-to-workspace-left = [ "<shift><alt>left" ];
      move-to-workspace-right = [ "<shift><alt>right" ];
      switch-to-workspace-1 = [ "<alt>1" ];
      switch-to-workspace-2 = [ "<alt>2" ];
      switch-to-workspace-3 = [ "<alt>3" ];
      switch-to-workspace-4 = [ "<alt>4" ];
      switch-to-workspace-5 = [ "<alt>5" ];
      switch-to-workspace-left = [ "<alt>left" ];
      switch-to-workspace-right = [ "<alt>right" ];
      toggle-fullscreen = [ "<super>f" ];
      unmaximize = [ "@as []" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      workspace-names = [ "1" "2" "3" "4" "5" ];
    };

    "org/gnome/file-roller/dialogs/extract" = {
      recreate-folders = true;
      skip-newer = false;
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 250;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/mutter" = {
      center-new-windows = true;
      edge-tiling = true;
      workspaces-only-on-primary = false;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "@as []" ];
      toggle-tiled-right = [ "@as []" ];
    };

    "org/gnome/nautilus/compression" = {
      default-compression-format = "zip";
    };

    "org/gnome/portal/filechooser/com/visualstudio/code" = {
      last-folder-path = "/home/juca/.dotfiles/nixfiles";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<super>e";
      command = "nautilus";
      name = "open-file-browser";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      disabled-extensions = [ "battery-indicator@jgotti.org" "launch-new-instance@gnome-shell-extensions.gcampax.github.com" "window-list@gnome-shell-extensions.gcampax.github.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "workspace-indicator@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" "just-perfection-desktop@just-perfection" "native-window-placement@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com" "Vitals@CoreCoding.com" "windowsNavigator@gnome-shell-extensions.gcampax.github.com" "caffeine@patapon.info" "appindicatorsupport@rgcjonas.gmail.com" "widgets@aylur" "logomenu@aryan_k" "space-bar@luchrioh" "top-bar-organizer@julian.gse.jsts.xyz" "rounded-window-corners@yilozt" "pop-shell@system76.com" "trayIconsReloaded@selfmade.pl" "gsconnect@andyholmes.github.io" "blur-my-shell@aunetx" "forge@jmmaranan.com" "bluetooth-quick-connect@bjarosze.gmail.com" "pano@elhan.io" "places-menu@gnome-shell-extensions.gcampax.github.com" "user-theme@gnome-shell-extensions.gcampax.github.com" ];
      favorite-apps = [ "firefox.desktop" "code.desktop" "org.gnome.Nautilus.desktop" "com.gexperts.Tilix.desktop" ];
      last-selected-power-profile = "balanced";
    };

    "org/gnome/shell/extensions/Logo-menu" = {
      menu-button-extensions-app = "com.mattjakeman.ExtensionManager.desktop";
      menu-button-icon-image = 23;
      menu-button-icon-size = 20;
      menu-button-terminal = "tilix";
      show-lockscreen = true;
      show-power-options = false;
    };

    "org/gnome/shell/extensions/bluetooth-quick-connect" = {
      bluetooth-auto-power-on = true;
      refresh-button-on = true;
      show-battery-value-on = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/hidetopbar" = {
      compatibility = false;
    };

    "org/gnome/shell/extensions/caffeine" = {
      indicator-position-max = 2;
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      display-mode = 0;
    };

    "org/gnome/shell/extensions/forge" = {
      dnd-center-layout = "stacked";
      tiling-mode-enabled = false;
      window-gap-hidden-on-single = true;
      window-gap-size = mkUint32 2;
      window-gap-size-increment = mkUint32 2;
    };

    "org/gnome/shell/extensions/pop-shell" = {
      smart-gaps = true;
      snap-to-grid = true;
      tile-by-default = true;
    };

    "org/gnome/shell/extensions/rounded-window-corners" = {
      custom-rounded-corner-settings = "@a{sv} {}";
      global-rounded-corner-settings = "{'padding': <{'left': <uint32 1>, 'right': <uint32 1>, 'top': <uint32 1>, 'bottom': <uint32 1>}>, 'keep_rounded_corners': <{'maximized': <false>, 'fullscreen': <false>}>, 'border_radius': <uint32 12>, 'smoothing': <uint32 0>}";
      settings-version = mkUint32 5;
    };

    "org/gnome/shell/extensions/top-bar-organizer" = {
      center-box-order = [ "Media Player" "dateMenu" ];
      left-box-order = [ "menuButton" "Notifications" "Space Bar" "activities" "appMenu" "places-menu" ];
      right-box-order = [ "pano@elhan.io" "ForgeExt" "workspace-indicator" "TrayIconsReloaded" "keyboard" "dwellClick" "screenRecording" "screenSharing" "drive-menu" "pop-shell" "vitalsMenu" "quickSettings" "a11y" ];
    };

    "org/gnome/shell/extensions/vitals" = {
      hide-icons = false;
      hide-zeros = false;
      include-static-info = false;
      show-battery = false;
      show-fan = false;
      show-system = false;
      show-voltage = false;
      update-time = 4;
      use-higher-precision = true;
    };

    "org/gnome/shell/world-clocks" = {
      locations = "@av []";
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = true;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
    };

    "org/virt-manager/virt-manager/confirm" = {
      delete-storage = false;
      forcepoweroff = false;
      removedev = false;
    };

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };

    "org/virt-manager/virt-manager/details" = {
      show-toolbar = true;
    };

    "org/virt-manager/virt-manager/paths" = {
      media-default = "/media/Data/System Images/Linux/NixOS";
    };

    "org/virt-manager/virt-manager/urls" = {
      isos = [ "/media/Data/System Images/Linux/NixOS/nixos-plasma5-23.05.4726.aeefe2054617-x86_64-linux.iso" "/media/Data/System Images/Linux/NixOS/nixos-gnome-23.05.1139.572d2693045-x86_64-linux.iso" "/media/Data/System Images/Linux/NixOS/nixos-minimal-23.05.4335.898cb2064b6e-x86_64-linux.iso" ];
    };
  };
}
