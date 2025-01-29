{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkForce;

  apps = with pkgs; [
    gnome-usage

    gnome-extension-manager
    glide-media-player
    gnome-tweaks
    # glide-media-player # video player
    decibels # audio player
    papers # document viewer
  ];

  extensions = with pkgs.gnomeExtensions; [
    appindicator
    dash-to-dock
    emoji-copy
    just-perfection
    logo-menu
    wireless-hid
    wifi-qrcode
    workspace-switcher-manager
    start-overlay-in-application-view
    tiling-assistant
    vitals
  ];
in
{
  services = {
    gpg-agent.pinentryPackage = mkForce pkgs.pinentry-gnome3;
    gnome-keyring = {
      enable = true;
      components = [ "secrets" "ssh" ];
    };
  };

  home.packages = apps ++ extensions;

  programs = {
    gnome-shell = {
      enable = true;
    };
  };

  desktop.apps = {
    notes.gnome-text.enable = true;
    video.mpv.enable = mkDefault true;
  };

  dconf.settings = with lib.hm.gvariant; {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };
    ### Default
    "org/gnome/desktop/default/applications/terminal" = {
      exec = "blackbox";
      # exec-arg = "-e";
    };

    ### Mouse
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
      left-handed = false;
      natural-scroll = false;
    };

    ### TouchPad
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    ### Timezone
    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

    ### Desktop
    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      # cursor-size = mkInt32 24;
      cursor-theme = "catppuccin-mocha-blue-cursors";
      document-font-name = "Work Sans 12";
      enable-hot-corners = false;
      # font-name = "Work Sans 12";
      gtk-theme = "catppuccin-mocha-blue-standard";
      icon-theme = "Papirus-Dark";
      monospace-font-name = "FiraCode Nerd Font Mono Medium 11";
      show-battery-percentage = true;
      text-scaling-factor = mkDouble 1.0;
    };

    ### Session
    "org/gnome/desktop/session" = {
      idle-delay = mkInt32 900;
    };

    ### Sound
    "org/gnome/desktop/sound" = {
      theme-name = "freedesktop";
    };

    ### Keybindings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Alt>e"; # "<Super>e";
      name = "File Manager";
      command = "nautilus -w ~";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Alt>Return"; # "<Super>t";
      name = "Terminal";
      command = "blackbox";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Ctrl><Alt>t";
      name = "Terminal";
      command = "blackbox";
    };

    ### Power
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = mkInt32 0;
      sleep-inactive-ac-type = "nothing";
    };

    ### Workspace keybindings
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = [ "<Alt>1" "<Alt>Home" "<Super>Home" ];
      switch-to-workspace-2 = [ "<Alt>2" ];
      switch-to-workspace-3 = [ "<Alt>3" ];
      switch-to-workspace-4 = [ "<Alt>4" ];
      switch-to-workspace-5 = [ "<Alt>5" ];
      switch-to-workspace-6 = [ "<Alt>6" ];
      switch-to-workspace-7 = [ "<Alt>7" ];
      switch-to-workspace-8 = [ "<Alt>8" ];
      switch-to-workspace-down = [ "<Alt>Down" ];
      switch-to-workspace-last = [ "<Alt>End" "<Super>End" ];
      switch-to-workspace-left = [ "<Alt>Left" "<Super>Page_Up" ];
      switch-to-workspace-right = [ "<Alt>Right" "<Super>Page_Down" ];
      switch-to-workspace-up = [ "<Alt>Up" ];
      move-to-workspace-1 = [ "<Alt><Shift>1" ];
      move-to-workspace-2 = [ "<Alt><Shift>2" ];
      move-to-workspace-3 = [ "<Alt><Shift>3" ];
      move-to-workspace-4 = [ "<Alt><Shift>4" ];
      move-to-workspace-5 = [ "<Alt><Shift>5" ];
      move-to-workspace-6 = [ "<Alt><Shift>6" ];
      move-to-workspace-7 = [ "<Alt><Shift>7" ];
      move-to-workspace-8 = [ "<Alt><Shift>8" ];
      move-to-workspace-down = [ "<Alt><Shift>Down" ];
      move-to-workspace-last = [ "<Alt><Shift>End" ];
      move-to-workspace-left = [ "<Alt><Shift>Left" "<Alt><Shift>Page_Up" ];
      move-to-workspace-right = [ "<Alt><Shift>Right" "<Alt><Shift>Page_Down" ];
      move-to-workspace-up = [ "<Alt><Shift>Up" ];

      # Disable maximise/unmaximise because tiling-assistant extension handles it
      maximize = mkEmptyArray type.string;
      unmaximize = mkEmptyArray type.string;
    };

    ### Workspace Preferences
    "org/gnome/desktop/wm/preferences" = {
      audible-bell = false;
      # button-layout = "close,minimize,maximize";
      titlebar-font = "Work Sans Semi-Bold 11";
    };

    ### Mutter
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = false;
      # edge-tiling = false; # Disable Mutter edge-tiling because tiling-assistant extension handles it
    };
    "org/gnome/mutter/keybindings" = {
      # Disable Mutter toggle-tiled because tiling-assistant extension handles it
      toggle-tiled-left = mkEmptyArray type.string;
      toggle-tiled-right = mkEmptyArray type.string;
    };

    ### Terminal
    "com/raggesilver/BlackBox" = {
      theme-dark = "Dracula";
      was-maximized = false;
      window-height = "uint32 576";
      window-width = "uint32 1068";
    };

    ### Clock
    "org/gnome/clocks" = {
      timers = [ "{'duration': <900>, 'name': <''>}" ];
    };

    ### Nautilus
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };

    ### GTK
    "org/gtk/Settings/FileChooser" = {
      clock-format = "24h";
    };

    "org/gtk/settings/file-chooser" = {
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
    };

    ### GTK 4
    "org/gtk/gtk4/Settings/FileChooser" = {
      clock-format = "24h";
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
    };

    # "org/gnome/desktop/input-sources" = {
    #   xkb-options = [
    #     "grp:alt_shift_toggle"
    #     "caps:none"
    #   ];
    # };

    "org/gnome/shell" = {
      disabled-extensions = mkEmptyArray type.string;
      # disable-user-extensions = false;

      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "emoji-copy@felipeftn"
        "freon@UshakovVasilii_Github.yahoo.com"
        "just-perfection-desktop@just-perfection"
        "logomenu@aryan_k"
        "start-overlay-in-application-view@Hex_cz"
        "tiling-assistant@leleat-on-github"
        "Vitals@CoreCoding.com"
        "wireless-hid@chlumskyvaclav.gmail.com"
        "wifiqrcode@glerro.pm.me"
        "workspace-switcher-manager@G-dH.github.com"
      ];

      favorite-apps = [
        "firefox.desktop"
        "code.desktop"
        "org.gnome.Nautilus.desktop"
      ];

      ### Extensions
      # "org/gnome/shell/extensions/auto-move-windows" = {
      #   application-list = [
      #     "brave-browser.desktop:1"
      #     "Wavebox.desktop:2"
      #     "discord.desktop:2"
      #     "org.telegram.desktop.desktop:3"
      #     "org.squidowl.halloy.desktop:3"
      #     "org.gnome.Fractal.desktop:3"
      #     "code.desktop:4"
      #     "GitKraken.desktop:4"
      #     "com.obsproject.Studio.desktop:6"
      #   ];
      # };

    };

    # Dash-to-dock
    "org/gnome/shell/extensions/dash-to-dock" = {
      click-action = "skip";
      disable-overview-on-startup = true;
      dock-position = "LEFT";
      hot-keys = true;
      scroll-action = "cycle-windows";
      show-trash = false;
      background-opacity = mkDouble 0.0;
      transparency-mode = "FIXED";
    };

    # Freon
    "org/gnome/shell/extensions/freon" = {
      hot-sensors = [ "__average__" ];
    };

    # Tilling-assistant
    "org/gnome/shell/extensions/tiling-assistant" = {
      enable-advanced-experimental-features = true;
      show-layout-panel-indicator = true;
      single-screen-gap = mkInt32 10;
      window-gap = mkInt32 10;
      maximize-with-gap = true;
    };

    # Vitals
    "org/gnome/shell/extensions/vitals" = {
      alphabetize = false;
      fixed-widths = true;
      include-static-info = false;
      menu-centered = true;
      monitor-cmd = "gnome-usage";
      network-speed-format = mkInt32 1;
      show-fan = false;
      show-temperature = false;
      show-voltage = false;
      update-time = mkInt32 2;
      use-higher-precision = false;
    };

    # Emoji copy
    "org/gnome/shell/extensions/emoji-copy" = {
      always-show = false;
      emoji-keybind = [ "<Primary><Alt>e" ];
    };
    # Just-perfection
    "org/gnome/shell/extensions/just-perfection" = {
      panel-button-padding-size = mkInt32 5;
      panel-indicator-padding-size = mkInt32 3;
      #startup-status = mkInt32 0;
      window-demands-attention-focus = true;
      workspaces-in-app-grid = false;
    };
    # Logo Menu
    "org/gnome/shell/extensions/Logo-menu" = {
      menu-button-system-monitor = "gnome-usage";
      menu-button-icon-image = mkInt32 23;
      # menu-button-system-monitor = "gnome-usage";
      menu-button-terminal = "blackbox";
      show-activities-button = true;
      symbolic-icon = true;
    };
    # Wireless Hid
    "org/gnome/shell/extensions/wireless-hid" = {
      panel-box-index = mkInt32 4;
    };
    # Workspace Switcher
    "org/gnome/shell/extensions/workspace-switcher-manager" = {
      active-show-ws-name = true;
      active-show-app-name = false;
      inactive-show-ws-name = true;
      inactive-show-app-name = false;
    };
    # Workspaces
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = mkInt32 8;
      workspace-names = [
        "Web"
        "Work"
        "Chat"
        "Code"
        "Term"
        "Cast"
        "Virt"
        "Fun"
      ];
    };
  };
}
