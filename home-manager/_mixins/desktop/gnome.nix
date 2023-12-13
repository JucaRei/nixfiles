{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  home = {
    packages = with pkgs; [
      layan-gtk-theme
      libnotify
      gparted
      gaphor
      warp
      curtail
      evince # document viewer
      deepin.deepin-gtk-theme
      # gthumb
      # qogir-icon-theme
      nautilus-open-any-terminal
    ] ++ (with pkgs.gnomeExtensions; [
      logo-menu
      rounded-window-corners
      window-is-ready-remover
      custom-accent-colors
      appindicator
      vitals
      space-bar
      top-bar-organizer
      blur-my-shell
      just-perfection
      caffeine
      bluetooth-quick-connect
      forge
      dash-to-dock
      pano
      # aylurs-widgets
      # google-earth-wallpaper
      # pop-shell
      # clipboard-indicator
      # user-themes
      # hide-activities-button
      # mutter
      # libgnome-keyring
      # gsconnect
      # arcmenu
      # battery-indicator-upower
      # tray-icons-reloaded
      # removable-drive-menu
      # dash-to-panel
      # workspace-indicator-2
      # pip-on-top
      # fullscreen-avoider
      # tailscale-qs
      # tailscale-status
    ]) ++ (with pkgs.gnome3; [
      gvfs
      nautilus
    ]) ++ (with pkgs.gnome;[
      dconf-editor
      adwaita-icon-theme
      gnome-tweaks
      nautilus-python
    ]);

    # Others
    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features
    sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
      # GTK_THEME = "palenight";
      # GTK_THEME = "WhiteSur-light-solid-pink";
      GTK_THEME = "Catppuccin-Frappe-Standard-Blue-Dark";

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
      # name = "palenight";
      # package = pkgs.palenight-theme;
      name = "Catppuccin-Frappe-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk;
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

    "com/gexperts/Tilix" = {
      background-image-mode = "stretch";
      control-scroll-zoom = true;
      copy-on-select = false;
      enable-wide-handle = true;
      focus-follow-mouse = true;
      new-window-inherit-state = true;
      prompt-on-close = false;
      prompt-on-delete-profile = true;
      quake-height-percent = 40;
      quake-hide-headerbar = false;
      quake-specific-monitor = 0;
      sidebar-on-right = false;
      tab-position = "top";
      terminal-title-style = "small";
      theme-variant = "dark";
      use-overlay-scrollbar = true;
      window-save-state = true;
      window-state = 87168;
    };

    "com/gexperts/Tilix/keybindings" = {
      app-preferences = "<Primary>p";
      session-add-down = "<Primary>t";
      session-add-right = "<Primary>f";
      session-close = "<Primary>q";
      terminal-close = "<Primary>w";
    };

    "com/gexperts/Tilix/profiles" = {
      list = [ "2b7c4080-0ddd-46c5-8f23-563fd3ba789d" ];
    };

    "com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
      background-color = "#263238";
      background-transparency-percent = 2;
      badge-color-set = false;
      badge-font = "Monospace 24";
      badge-position = "southeast";
      badge-text = "";
      badge-use-system-font = true;
      bold-color-set = false;
      bold-is-bright = true;
      cursor-colors-set = false;
      dim-transparency-percent = 0;
      foreground-color = "#A1B0B8";
      highlight-colors-set = false;
      login-shell = true;
      palette = [ "#252525" "#FF5252" "#C3D82C" "#FFC135" "#42A5F5" "#D81B60" "#00ACC1" "#F5F5F5" "#708284" "#FF5252" "#C3D82C" "#FFC135" "#42A5F5" "#D81B60" "#00ACC1" "#F5F5F5" ];
      scrollback-unlimited = true;
      terminal-bell = "sound";
      text-blink-mode = "always";
      use-theme-colors = false;
      visible-name = "Default";
    };

    "com/mattjakeman/ExtensionManager" = {
      last-used-version = "0.4.0";
    };

    "org/blueman/plugins/powermanager" = {
      auto-power-on = "@mb true";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "stretched";
      picture-uri = "file://${../config/wallpapers/nix-asci.png}";
      picture-uri-dark = "file://${../config/wallpapers/nix-asci.png}";
      primary-color = "#ac5e0b";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/interface" = {
      clock-show-seconds = true;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      # cursor-theme = "Breeze_Hacked";
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
      num-workspaces = 5;
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

    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "small";
    };

    "org/gnome/portal/filechooser/com/visualstudio/code" = {
      last-folder-path = "/home/juca/.dotfiles/nixfiles";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "tilix";
      name = "open-terminal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<super>e";
      command = "nautilus";
      name = "open-file-browser";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Super>Return";
      command = "tilix";
      name = "Tilix";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [ "battery-indicator@jgotti.org" "launch-new-instance@gnome-shell-extensions.gcampax.github.com" "window-list@gnome-shell-extensions.gcampax.github.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "workspace-indicator@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" "just-perfection-desktop@just-perfection" "native-window-placement@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com" "Vitals@CoreCoding.com" "windowsNavigator@gnome-shell-extensions.gcampax.github.com" "caffeine@patapon.info" "widgets@aylur" "logomenu@aryan_k" "space-bar@luchrioh" "top-bar-organizer@julian.gse.jsts.xyz" "rounded-window-corners@yilozt" "pop-shell@system76.com" "trayIconsReloaded@selfmade.pl" "gsconnect@andyholmes.github.io" "blur-my-shell@aunetx" "forge@jmmaranan.com" "bluetooth-quick-connect@bjarosze.gmail.com" "pano@elhan.io" "places-menu@gnome-shell-extensions.gcampax.github.com" "user-theme@gnome-shell-extensions.gcampax.github.com" "appindicatorsupport@rgcjonas.gmail.com" ];
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
      bluetooth-auto-power-off = true;
      bluetooth-auto-power-off-interval = 120;
      bluetooth-auto-power-on = true;
      refresh-button-on = true;
      show-battery-value-on = true;
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      brightness = 0.6;
      sigma = 40;
    };

    "org/gnome/shell/extensions/blur-my-shell/hidetopbar" = {
      compatibility = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      brightness = 0.5;
      customize = true;
      sigma = 59;
    };

    "org/gnome/shell/extensions/caffeine" = {
      indicator-position-max = 2;
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      display-mode = 0;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = false;
      autohide-in-fullscreen = false;
      background-color = "rgb(129,61,156)";
      background-opacity = 0.8;
      custom-background-color = true;
      custom-theme-shrink = true;
      dash-max-icon-size = 40;
      disable-overview-on-startup = true;
      dock-position = "BOTTOM";
      height-fraction = 0.9;
      intellihide-mode = "MAXIMIZED_WINDOWS";
      isolate-workspaces = true;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "eDP-1-1";
      running-indicator-style = "SQUARES";
      show-apps-at-top = true;
      show-mounts-only-mounted = true;
      transparency-mode = "DYNAMIC";
    };

    "org/gnome/shell/extensions/forge" = {
      dnd-center-layout = "stacked";
      tiling-mode-enabled = false;
      window-gap-hidden-on-single = true;
      window-gap-size = mkUint32 2;
      window-gap-size-increment = mkUint32 2;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = true;
      app-menu-icon = true;
      keyboard-layout = false;
      looking-glass-height = 0;
      panel = true;
      panel-in-overview = true;
      panel-notification-icon = true;
      power-icon = true;
      startup-status = 0;
      theme = true;
      world-clock = false;
    };

    "org/gnome/shell/extensions/pano" = {
      is-in-incognito = false;
      play-audio-on-copy = false;
      send-notification-on-copy = false;
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

    "org/gnome/shell/extensions/user-theme" = {
      name = "Catppuccin-Frappe-Standard-Blue-Dark";
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
      image-default = "/media/Shared/virtualmachines/Virt-manager";
      media-default = "/media/Data/System Images/Linux/NixOS";
    };

    "org/virt-manager/virt-manager/urls" = {
      isos = [ "/media/Data/System Images/Linux/NixOS/nixos-plasma5-23.05.4726.aeefe2054617-x86_64-linux.iso" "/media/Data/System Images/Linux/NixOS/nixos-gnome-23.05.1139.572d2693045-x86_64-linux.iso" "/media/Data/System Images/Linux/NixOS/nixos-minimal-23.05.4335.898cb2064b6e-x86_64-linux.iso" ];
    };
  };
}
