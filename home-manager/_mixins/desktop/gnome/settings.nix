{ lib, pkgs, ... }: with lib.gvariant;
let
  extensions = with pkgs; with gnomeExtensions; [
    user-themes
    logo-menu
    emoji-copy
    just-perfection
    wireless-hid
    night-theme-switcher
    wifi-qrcode
    workspace-switcher-manager
    # logo-menu
    # blur-my-shell
    # pano
    # desktop-cube
    # desktop-clock
    # pop-shell
    # vitals
    # docker
    # unblank
    # custom-accent-colors
    # tailscale-qs
    # tailscale-status
    # rounded-window-corners
    # window-is-ready-remover
    # custom-accent-colors
    # appindicator
    # vitals
    # space-bar
    # top-bar-organizer
    # caffeine
    # bluetooth-quick-connect
    # forge
    # dash-to-dock
    # pano
    # # aylurs-widgets
    # # google-earth-wallpaper
    # # pop-shell
    # # clipboard-indicator
    # # user-themes
    # # hide-activities-button
    # # mutter
    # # libgnome-keyring
    # # gsconnect
    # # arcmenu
    # # battery-indicator-upower
    # # tray-icons-reloaded
    # # removable-drive-menu
    # # dash-to-panel
    # # workspace-indicator-2
    # # pip-on-top
    # # fullscreen-avoider
    # tailscale-qs
    # tailscale-status
  ];
in
{
  home = {
    packages = with pkgs; [
      extensions
    ];
  };
  dconf.settings = {
    "ca/desrt/dconf-editor" = { show-warning = false; };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

    "org/gnome/desktop/default/applications/terminal" = {
      exec = "gnome-console";
      exec-arg = "-e";
    };

    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      cursor-size = 24;
      cursor-theme = "Adwaita";
      document-font-name = "Work Sans 12";
      enable-hot-corners = false;
      font-name = "Work Sans 12";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Adwaita";
      monospace-font-name = "FiraCode Nerd Font Mono Medium 13";
      show-battery-percentage = true;
      text-scaling-factor = mkDouble 1.0;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      natural-scroll = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkInt32 900;
    };

    "org/gnome/desktop/sound" = {
      theme-name = "freedesktop";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = [ "<Alt>1" "<Control><Alt>Home" "<Super>Home" ];
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
      move-to-workspace-1 = [ "<Shift><Alt>1" ];
      move-to-workspace-2 = [ "<Shift><Alt>2" ];
      move-to-workspace-3 = [ "<Shift><Alt>3" ];
      move-to-workspace-4 = [ "<Shift><Alt>4" ];
      move-to-workspace-5 = [ "<Shift><Alt>5" ];
      move-to-workspace-6 = [ "<Shift><Alt>6" ];
      move-to-workspace-7 = [ "<Shift><Alt>7" ];
      move-to-workspace-8 = [ "<Shift><Alt>8" ];
      move-to-workspace-down = [ "<Shift><Alt>Down" ];
      move-to-workspace-last = [ "<Shift><Alt>End" ];
      move-to-workspace-left = [ "<Shift><Alt>Left" "<Shift><Alt>Page_Up" ];
      move-to-workspace-right = [ "<Alt>Right" "<Shift>Page_Down" ];
      move-to-workspace-up = [ "<Alt>Up" ];
      # Disable maximise/unmaximise because tiling-assistant extension handles it
      maximize = mkEmptyArray type.string;
      unmaximize = mkEmptyArray type.string;
      # toggle-fullscreen = ["<super>f"];
      # unmaximize = ["@as []"];
    };


    "org/gnome/desktop/wm/preferences" = {
      audible-bell = false;
      button-layout = ":minimize,maximize,close";
      titlebar-font = "Work Sans Semi-Bold 12";
    };

    "org/gnome/GWeather" = {
      temperature-unit = "centigrade";
    };

    "org/gnome/mutter" = {
      # dynamic-workspaces = false;
      dynamic-workspaces = true;
      workspaces-only-on-primary = false;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      home = "[ <Alt>e ]";
      search="[ <Alt>space ]";
      www="[ <Alt>b ]";
      calculator="[ <Alt>c ]";
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>t";
      command = "gnome-console";
      name = "Terminal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Primary><Alt>t";
      command = "gnome-console";
      name = "Terminal";
    };

    "org/gnome/TextEditor" = {
      custom-font = "FiraCode Nerd Font Mono Medium 13";
      highlight-current-line = true;
      indent-style = "space";
      show-line-numbers = true;
      show-map = true;
      show-right-margin = true;
      style-scheme = "builder-dark";
      tab-width = mkInt32 4;
      use-system-font = false;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = mkInt32 0;
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
        enabled-extensions = builtins.map (p: p.extensionUuid) extensions;
        "favorite-apps" = [ "librewolf.desktop"  ];
      };
    };

    "org/gnome/settings-daemon/plugins/color" = {
    night-light-enabled=true;
night-light-schedule-automatic=false;
night-light-schedule-from=19.499999999999972;
night-light-schedule-to=7.0;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      click-action = "skip";
      disable-overview-on-startup = true;
      dock-position = "LEFT";
      hot-keys = true;
      scroll-action = "cycle-windows";
      show-trash = false;
    };

    "org/gnome/shell/extensions/emoji-copy" = {
      always-show = false;
      emoji-keybind = [ "<Primary><Alt>e" ];
    };

    "org/gnome/shell/extensions/just-perfection" = {
      panel-button-padding-size = mkInt32 5;
      panel-indicator-padding-size = mkInt32 3;
      #startup-status = mkInt32 0;
      window-demands-attention-focus = true;
      workspaces-in-app-grid = false;
    };

    "org/gnome/shell/extensions/Logo-menu" = {
      menu-button-icon-image = mkInt32 23;
      menu-button-system-monitor = "gnome-usage";
      menu-button-terminal = "gnome-console";
      show-activities-button = true;
      symbolic-icon = true;
    };

    "org/gnome/shell/extensions/wireless-hid" = {
      panel-box-index = mkInt32 4;
    };

    "org/gnome/shell/extensions/workspace-switcher-manager" = {
      active-show-ws-name = true;
      active-show-app-name = false;
      inactive-show-ws-name = true;
      inactive-show-app-name = false;
    };

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
  };
}
