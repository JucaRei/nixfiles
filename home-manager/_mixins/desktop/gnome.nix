{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  home = {
    packages = with pkgs; [
      gnomeExtensions.logo-menu
      # gnomeExtensions.aylurs-widgets
      gnomeExtensions.rounded-window-corners
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
      # gnomeExtensions.arcmenu
      # gnomeExtensions.battery-indicator-upower
      gnomeExtensions.tray-icons-reloaded
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
    ];
    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features
    sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
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
      package = pkgs.layan-gtk-theme;
      name = "Layan-dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "EPapirus-dark";
    };
  };

  # Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "com/gexperts/Tilix" = {
      window-style = "normal";
    };

    "com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
      background-color = "#300A24";
      badge-color = "#AC7EA8";
      badge-color-set = false;
      bold-color-set = false;
      cursor-colors-set = false;
      foreground-color = "#FFFFFF";
      highlight-colors-set = false;
      palette = [ "#2E3436" "#CC0000" "#4E9A06" "#C4A000" "#3465A4" "#75507B" "#06989A" "#D3D7CF" "#555753" "#EF2929" "#8AE234" "#FCE94F" "#729FCF" "#AD7FA8" "#34E2E2" "#EEEEEC" ];
      use-theme-colors = false;
      visible-name = "Default";
    };

    "com/mattjakeman/ExtensionManager" = {
      last-used-version = "0.4.0";
    };

    "org/gnome/clocks/state/window" = {
      maximized = false;
      panel-id = "world";
      size = mkTuple [ 870 690 ];
    };

    "org/gnome/control-center" = {
      last-panel = "background";
      window-state = mkTuple [ 948 1035 ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "YaST" ];
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.eog.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      picture-options = "zoom";
    };

    "org/gnome/desktop/input-sources" = {
      show-all-sources = true;
      sources = [ (mkTuple [ "xkb" "br" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
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
      gtk-theme = "Layan-dark";
      icon-theme = "EPapirus-dark";
      locate-pointer = true;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "codium" "org-gnome-tweaks" "code" "org-gnome-fileroller" ];
    };

    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };

    "org/gnome/desktop/notifications/application/codium" = {
      application-id = "codium.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-fileroller" = {
      application-id = "org.gnome.FileRoller.desktop";
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
      natural-scroll = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
    };

    "org/gnome/desktop/screensaver" = {
      picture-options = "zoom";
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      workspace-names = [ "1" "2" "3" "4" ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      # maximize = ["<super>up"];                   # Floating
      # unmaximize = ["<super>down"];
      maximize = [ "@as []" ]; # Tiling
      unmaximize = [ "@as []" ];
      switch-to-workspace-left = [ "<alt>left" ];
      switch-to-workspace-right = [ "<alt>right" ];
      switch-to-workspace-1 = [ "<alt>1" ];
      switch-to-workspace-2 = [ "<alt>2" ];
      switch-to-workspace-3 = [ "<alt>3" ];
      switch-to-workspace-4 = [ "<alt>4" ];
      switch-to-workspace-5 = [ "<alt>5" ];
      move-to-workspace-left = [ "<shift><alt>left" ];
      move-to-workspace-right = [ "<shift><alt>right" ];
      move-to-workspace-1 = [ "<shift><alt>1" ];
      move-to-workspace-2 = [ "<shift><alt>2" ];
      move-to-workspace-3 = [ "<shift><alt>3" ];
      move-to-workspace-4 = [ "<shift><alt>4" ];
      move-to-workspace-5 = [ "<shift><alt>5" ];
      move-to-monitor-left = [ "<super><alt>left" ];
      move-to-monitor-right = [ "<super><alt>right" ];
      close = [ "<super>q" "<alt>f4" ];
      toggle-fullscreen = [ "<super>f" ];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
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

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 480;
      window-width = 600;
    };

    "org/gnome/font-manager" = {
      compare-background-color = "rgb(255,255,255)";
      compare-foreground-color = "rgb(0,0,0)";
      compare-list = [ ];
      google-fonts-background-color = "rgb(255,255,255)";
      google-fonts-foreground-color = "rgb(0,0,0)";
      is-maximized = false;
      language-filter-list = [ ];
      preview-page = 2;
      selected-category = "0";
      selected-font = "18:6";
      window-position = mkTuple [ 45 29 ];
      window-size = mkTuple [ 900 603 ];
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
      center-new-windows = true;
      edge-tiling = false;
    };

    "org/gnome/mutter/keybindings" = {
      #toggle-tiled-left = ["<super>left"];         # Floating
      #toggle-tiled-right = ["<super>right"];
      toggle-tiled-left = [ "@as []" ]; # Tiling
      toggle-tiled-right = [ "@as []" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<super>return";
      command = "tilix";
      name = "open-terminal";
    };

    # "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
    #   binding = "<super>t";
    #   command = "emacs";
    #   name = "open-editor";
    # };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<super>e";
      command = "nautilus";
      name = "open-file-browser";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 1920 1051 ];
    };

    "org/gnome/rhythmbox/plugins" = {
      active-plugins = [ "rb" "power-manager" "mpris" "iradio" "generic-player" "audiocd" "android" "rb" "power-manager" "mpris" "iradio" "generic-player" "audiocd" "android" ];
    };

    "org/gnome/rhythmbox/podcast" = {
      download-interval = "manual";
    };

    "org/gnome/rhythmbox/rhythmdb" = {
      locations = [ "file:///home/juca/Music" "file:///home/juca/Music" ];
      monitor-library = true;
    };

    "org/gnome/rhythmbox/sources" = {
      browser-views = "genres-artists-albums";
      visible-columns = [ "post-time" "duration" "track-number" "album" "genre" "beats-per-minute" "play-count" "artist" "post-time" "duration" "track-number" "album" "genre" "beats-per-minute" "play-count" "artist" ];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      app-picker-layout = "[{'com.hunterwittenborn.Celeste.desktop': <{'position': <0>}>, 'org.gnome.Weather.desktop': <{'position': <1>}>, 'ca.desrt.dconf-editor.desktop': <{'position': <2>}>, 'org.gnome.clocks.desktop': <{'position': <3>}>, 'emacs.desktop': <{'position': <4>}>, 'emacsclient.desktop': <{'position': <5>}>, 'org.gnome.Extensions.desktop': <{'position': <6>}>, 'org.gnome.Calculator.desktop': <{'position': <7>}>, 'firefox.desktop': <{'position': <8>}>, 'simple-scan.desktop': <{'position': <9>}>, 'gparted.desktop': <{'position': <10>}>, 'org.gnome.Settings.desktop': <{'position': <11>}>, 'gsmartcontrol.desktop': <{'position': <12>}>, 'org.gnome.gThumb.desktop': <{'position': <13>}>, 'htop.desktop': <{'position': <14>}>, 'Utilities': <{'position': <15>}>, 'maestral.desktop': <{'position': <16>}>, 'micro.desktop': <{'position': <17>}>, 'pavucontrol.desktop': <{'position': <18>}>, 'org.gnome.Software.desktop': <{'position': <19>}>}]";
      disabled-extensions = [ "battery-indicator@jgotti.org" "launch-new-instance@gnome-shell-extensions.gcampax.github.com" "places-menu@gnome-shell-extensions.gcampax.github.com" "window-list@gnome-shell-extensions.gcampax.github.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "workspace-indicator@gnome-shell-extensions.gcampax.github.com" "bluetooth-quick-connect@bjarosze.gmail.com" ];
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "just-perfection-desktop@just-perfection"
        "native-window-placement@gnome-shell-extensions.gcampax.github.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
        "Vitals@CoreCoding.com"
        "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
        "caffeine@patapon.info"
        "appindicatorsupport@rgcjonas.gmail.com"
        "widgets@aylur"
        "logomenu@aryan_k"
        "space-bar@luchrioh"
        "top-bar-organizer@julian.gse.jsts.xyz"
        "rounded-window-corners@yilozt"
        "pop-shell@system76.com"
        "trayIconsReloaded@selfmade.pl"
        "gsconnect@andyholmes.github.io"
        "blur-my-shell@aunetx"
        "forge@jmmaranan.com"
      ];
      favorite-apps = [
        "org.gnome.Calendar.desktop"
        "org.gnome.Photos.desktop"
        "org.gnome.Nautilus.desktop"
        "code.desktop"
        "firefox.desktop"
        "com.gexperts.Tilix.desktop"
      ];
      last-selected-power-profile = "power-saver";
      welcome-dialog-last-shown-version = "44.2";
    };

    "org/gnome/shell/extensions/Logo-menu" = {
      menu-button-icon-image = 23;
      menu-button-icon-size = 20;
      menu-button-terminal = "tilix";
    };

    "org/gnome/shell/extensions/aylurs-widgets" = {
      dash-links-names = [ "reddit" "youtube" "gmail" "twitter" "github" ];
      dash-links-urls = [ "https://www.reddit.com/" "https://www.youtube.com/" "https://www.gmail.com/" "https://twitter.com/" "https://www.github.com/" ];
    };

    "org/gnome/shell/extensions/bluetooth-quick-connect" = {
      bluetooth-auto-power-on = true;
      refresh-button-on = true;
      show-battery-value-on = true;
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      sigma = 50;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      style-dialogs = 3;
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      customize = true;
      sigma = 64;
      style-dash-to-dock = 0;
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      style-components = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      customize = false;
      override-background-dynamically = false;
      style-panel = 3;
    };

    "org/gnome/shell/extensions/caffeine" = {
      indicator-position-max = 2;
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      display-mode = 0;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = false;
      background-opacity = 0.3;
      custom-background-color = false;
      custom-theme-shrink = true;
      dash-max-icon-size = 39;
      disable-overview-on-startup = true;
      dock-position = "BOTTOM";
      height-fraction = 0.9;
      icon-size-fixed = false;
      isolate-monitors = true;
      isolate-workspaces = true;
      max-alpha = 0.8;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "Virtual-1";
      running-indicator-style = "DASHES";
      show-apps-at-top = true;
      show-icons-notifications-counter = false;
      transparency-mode = "FIXED";
    };

    "org/gnome/shell/extensions/forge" = {
      css-last-update = mkUint32 37;
      tiling-mode-enabled = true;
      dnd-center-layout = "stacked";
      window-gap-hidden-on-single = true;
      window-gap-size = mkUint32 2;
      window-gap-size-increment = mkUint32 2;
    };

    "org/gnome/shell/extensions/gsconnect" = {
      devices = [ ];
      id = "efe66a3c-1224-4e22-a252-96fea5feb631";
      name = "vm";
    };

    "org/gnome/shell/extensions/gsconnect/device/b790ceca-b551-481b-9650-c9da11ec6aac" = {
      incoming-capabilities = [ "kdeconnect.battery" "kdeconnect.battery.request" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report" "kdeconnect.contacts.response_uids_timestamps" "kdeconnect.contacts.response_vcards" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.request" "kdeconnect.photo" "kdeconnect.photo.request" "kdeconnect.ping" "kdeconnect.presenter" "kdeconnect.runcommand" "kdeconnect.runcommand.request" "kdeconnect.sftp" "kdeconnect.share.request" "kdeconnect.sms.messages" "kdeconnect.systemvolume.request" "kdeconnect.telephony" ];
      last-connection = "lan://192.168.122.1:1716";
      name = "nitro";
      outgoing-capabilities = [ "kdeconnect.battery" "kdeconnect.battery.request" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report.request" "kdeconnect.contacts.request_all_uids_timestamps" "kdeconnect.contacts.request_vcards_by_uid" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.action" "kdeconnect.notification.reply" "kdeconnect.notification.request" "kdeconnect.photo" "kdeconnect.photo.request" "kdeconnect.ping" "kdeconnect.runcommand" "kdeconnect.runcommand.request" "kdeconnect.sftp.request" "kdeconnect.share.request" "kdeconnect.sms.request" "kdeconnect.sms.request_conversation" "kdeconnect.sms.request_conversations" "kdeconnect.systemvolume" "kdeconnect.telephony.request" "kdeconnect.telephony.request_mute" ];
      supported-plugins = [ "battery" "clipboard" "findmyphone" "mousepad" "mpris" "notification" "photo" "ping" "runcommand" "share" ];
      type = "laptop";
    };

    "org/gnome/shell/extensions/gsconnect/preferences" = {
      window-maximized = false;
      window-size = mkTuple [ 948 473 ];
    };

    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = false;
      activities-button = false;
      animation = 1;
      app-menu = true;
      app-menu-icon = true;
      background-menu = true;
      clock-menu = true;
      controls-manager-spacing-size = 0;
      dash = true;
      dash-icon-size = 0;
      double-super-to-appgrid = true;
      gesture = true;
      hot-corner = false;
      keyboard-layout = true;
      osd = true;
      osd-position = 0;
      panel = true;
      panel-arrow = true;
      panel-corner-size = 0;
      panel-in-overview = true;
      panel-notification-icon = true;
      panel-size = 0;
      power-icon = true;
      ripple-box = true;
      search = true;
      show-apps-button = true;
      startup-status = 0;
      theme = true;
      window-demands-attention-focus = false;
      window-picker-icon = true;
      window-preview-caption = true;
      window-preview-close-button = true;
      workspace = true;
      workspace-background-corner-size = 0;
      workspace-popup = true;
      workspace-switcher-should-show = true;
      workspace-wrap-around = false;
      workspaces-in-app-grid = true;
    };

    "org/gnome/shell/extensions/openweather" = {
      delay-ext-init = 30;
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
      left-box-order = [ "menuButton" "Notifications" "Space Bar" "activities" "appMenu" ];
      right-box-order = [ "ForgeExt" "workspace-indicator" "TrayIconsReloaded" "keyboard" "dwellClick" "screenRecording" "screenSharing" "drive-menu" "pop-shell" "vitalsMenu" "quickSettings" "a11y" ];
    };

    "org/gnome/shell/extensions/vitals" = {
      hide-icons = false;
      hide-zeros = false;
      include-static-info = false;
      show-battery = false;
      show-fan = true;
      show-system = false;
      show-voltage = false;
      update-time = 4;
      use-higher-precision = true;
    };

    "org/gnome/shell/world-clocks" = {
      locations = "@av []";
    };

    "org/gnome/software" = {
      check-timestamp = mkInt64 1699811139;
      first-run = false;
      flatpak-purge-timestamp = mkInt64 1699822954;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 1.0 0.9647058844566345 ]) (mkTuple [ 0.7058823704719543 0.6549019813537598 ]) (mkTuple [ 0.9686274528503418 0.6352941393852234 ]) (mkTuple [ 6.666667014360428e-2 0.7803921699523926 ]) (mkTuple [ 0.9254902005195618 0.3686274588108063 ]) ];
      selected-color = mkTuple [ true 1.0 ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
      window-size = mkTuple [ 859 327 ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 185;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 45 29 ];
      window-size = mkTuple [ 1203 902 ];
    };
  };
}
