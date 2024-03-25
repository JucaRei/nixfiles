{ lib, pkgs, ... }: with lib.gvariant;
let
  extensions = with pkgs; with gnomeExtensions; [
    ### Maclike
    app-menu-is-back
    quick-settings-tweaker
    logo-menu
    app-icons-taskbar

    ### Others
    user-themes
    # logo-menu
    emoji-copy
    just-perfection
    wireless-hid
    night-theme-switcher
    wifi-qrcode
    workspace-switcher-manager
    # blur-my-shell
    # pano
    # desktop-cube
    # desktop-clock
    # pop-shell
    vitals
    # docker
    # unblank
    # custom-accent-colors
    # tailscale-qs
    # tailscale-status
    # rounded-window-corners
    # window-is-ready-remover
    # custom-accent-colors
    # appindicator
    space-bar
    # top-bar-organizer
    # caffeine
    # bluetooth-quick-connect
    # forge
    dash-to-dock
    # pano
    # # aylurs-widgets
    # # google-earth-wallpaper
    # # pop-shell
    # # clipboard-indicator
    # # user-themes
    # # hide-activities-button
    # # mutter
    # # libgnome-keyring
    gsconnect
    # # arcmenu
    # # battery-indicator-upower
    tray-icons-reloaded
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
  home.packages = extensions;
  dconf.settings = {
    "ca/desrt/dconf-editor" = { show-warning = false; };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

    "org/gnome/desktop/default/applications/terminal" = {
      exec = "blackbox";
      exec-arg = "-e";
    };

    "org/gnome/desktop/default-applications/terminal" = {
      exec = "blackbox";
      exec-arg = "-e";
    };

    "org/gnome/Contacts" = {
      did-inital-setup = true;
      window-fullscreen = false;
      window-height = 600;
      window-maximized = false;
      window-width = 800;
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "br+abnt2" ]) ];
      per-window = false;
      sources = [ (mkTuple [ "xkb" "br" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };
    "com/raggesilver/BlackBox" = {
      theme-dark = "Dracula";
      was-maximized = false;
      window-height = "uint32 576";
      window-width = "uint32 1068";
    };

    "org/gnome/clocks" = {
      timers = [ "{'duration': <900>, 'name': <''>}" ];
    };

    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-weekday = true;
      clock-show-seconds = true;
      color-scheme = "prefer-dark";
      cursor-size = 24;
      cursor-theme = "Adwaita";
      enable-animations = true;
      locate-pointer = true;
      document-font-name = "Work Sans 12";
      enable-hot-corners = false;
      font-name = "Work Sans 12";
      monospace-font-name = "FiraCode Nerd Font Mono Medium 13";
      show-battery-percentage = true;
      toolbar-icons-size = "small";
      text-scaling-factor = mkDouble 1.0;
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      natural-scroll = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkInt32 "900";
    };

    # "org/gnome/system/location" = {
    #   enabled = true;
    # };

    "org/gnome/Weather/locations" = {
      locations = ''
        [<(uint32 2, <('São Paulo', 'SBMT', true, [(-0.41044326824509736, -0.8139052020289248)], [(-0.41073414481823473, -0.81361432545578749)])>)>]
      '';
    };

    "org/gnome/desktop/sound" = {
      theme-name = "freedesktop";
      allow-volume-above-100-percent = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      # activate-window-menu = "@as []";
      activate-window-menu = "<Super>space";
      close = [ "<Alt>q" ];
      switch-to-workspace-1 = [ "<Alt>1" "<Control><Alt>Home" "<Super>Home" ];
      # maximize = "@as []";
      # unmaximize = "@as []";
      maximize = "<Alt>Up";
      unmaximize = "<Alt>Down";
      cycle-group = "<Super>F6";
      cycle-group-backward = "<Shift><Super>F6";
      cycle-panels = "<Control><Alt>Escape";
      cycle-panels-backward = "<Shift><Control><Alt>Escape";
      cycle-windows = "<Super>Escape";
      cycle-windows-backward = "<Shift><Super>Escape";
      switch-to-workspace-2 = [ "<Alt>2" ];
      switch-to-workspace-3 = [ "<Alt>3" ];
      switch-to-workspace-4 = [ "<Alt>4" ];
      switch-to-workspace-5 = [ "<Alt>5" ];
      switch-to-workspace-6 = [ "<Alt>6" ];
      switch-to-workspace-7 = [ "<Alt>7" ];
      switch-to-workspace-8 = [ "<Alt>8" ];
      switch-to-workspace-down = [ "<Super>Down" ];
      switch-to-workspace-last = [ "<Super>End" "<Super>End" ];
      switch-to-workspace-left = [ "<Super>Left" "<Super>Page_Up" ];
      switch-to-workspace-right = [ "<Super>Right" "<Super>Page_Down" ];
      toggle-fullscreen = [ "<Alt>f" ];
      switch-to-workspace-up = [ "<Super>Up" ];
      move-to-workspace-1 = [ "<Shift><Alt>1" ];
      move-to-workspace-2 = [ "<Shift><Alt>2" ];
      move-to-workspace-3 = [ "<Shift><Alt>3" ];
      move-to-workspace-4 = [ "<Shift><Alt>4" ];
      move-to-workspace-5 = [ "<Shift><Alt>5" ];
      move-to-workspace-6 = [ "<Shift><Alt>6" ];
      move-to-workspace-7 = [ "<Shift><Alt>7" ];
      move-to-workspace-8 = [ "<Shift><Alt>8" ];
      move-to-workspace-down = [ "<Shift><Super>Down" ];
      move-to-workspace-last = [ "<Shift><Super>End" ];
      move-to-workspace-left = [ "<Shift><Super>Left" "<Shift><Super>Page_Up" ];
      move-to-workspace-right = [ "<Super>Right" "<Super>Page_Down" ];
      move-to-workspace-up = [ "<Super>Up" ];
      # Disable maximise/unmaximise because tiling-assistant extension handles it
      # toggle-fullscreen = ["<super>f"];
      # unmaximize = ["@as []"];
    };

    "org/gnome/evince/default" = {
      continuous = true;
      dual-page = false;
      dual-page-odd-left = false;
      enable-spellchecking = true;
      fullscreen = false;
      inverted-colors = false;
      show-sidebar = true;
      sidebar-page = "thumbnails";
      sidebar-size = 132;
      sizing-mode = "automatic";
      window-ratio = "(1.0, 0.54696789536266355)";
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
      edge-tiling = false;
      workspaces-only-on-primary = false;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = "@as []";
      toggle-tiled-right = "@as []";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      migrated-gtk-settings = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      home = [ "<Super>e" ];
      search = [ "<Super>space" ];
      control-center = [ "<Super>s" ];
      www = [ "<Super>b" ];
      calculator = [ "<Super>c" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
      magnifier-zoom-in = [ "<Super>equal" ];
      magnifier-zoom-out = [ "<Super>minus" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Alt>Return";
      command = "blackbox";
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
      tab-width = mkInt32 "4";
      use-system-font = false;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = "mkInt32 0";
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = builtins.map (p: p.extensionUuid) extensions;
      "favorite-apps" = [ "librewolf.desktop" "code.desktop" "org.gnome.Rhythmbox3.desktop" "io.github.mimbrero.WhatsAppDesktop.desktop" "org.gnome.Nautilus.desktop" ];
    };

    ########################
    ### Shell Extensions ###
    ########################

    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = true;
      background-menu = true;
      controls-manager-spacing-size = 0;
      dash = true;
      dash-icon-size = 0;
      double-super-to-appgrid = true;
      osd = true;
      panel = true;
      panel-in-overview = true;
      ripple-box = true;
      search = true;
      show-apps-button = true;
      startup-status = 1;
      theme = true;
      window-demands-attention-focus = false;
      window-picker-icon = true;
      window-preview-caption = true;
      window-preview-close-button = true;
      workspace = true;
      workspace-background-corner-size = 0;
      workspace-popup = true;
      workspaces-in-app-grid = true;
    };

    "org/gnome/shell/extensions/nightthemeswitcher" = {
      # gtk-variants = {
      #   day = "Adwaita";
      #   enabled = false;
      #   night = "Adwaita-dark";
      # };
      # shell-variants = {
      #   day = "";
      #   enabled = false;
      # };
      # time = {
      #   manual-schedule = true;
      #   nightthemeswitcher-ondemand-keybinding = [ "<Shift><Super>t" ];
      # };
    };

    "org/gnome/shell/extensions/nightthemeswitcher/gtk-variants" = {
      day = "Adwaita";
      enabled = false;
      night = "Adwaita-dark";
    };

    "org/gnome/shell/extensions/tiling-assistant" =
      {
        activate-layout0 = "@as [ ]";
        activate-layout1 = "@as []";
        activate-layout2 = "@as []";
        activate-layout3 = "@as []";
        active-window-hint = 1;
        active-window-hint-color = "rgb(53,132,228)";
        auto-tile = "@as []";
        center-window = "@as []";
        debugging-free-rects = "@as []";
        debugging-show-tiled-rects = "@as []";
        default-move-mode = 0;
        dynamic-keybinding-behavior = 1;
        import-layout-examples = false;
        last-version-installed = 44;
        restore-window = [ "<Super>Down" ];
        search-popup-layout = "@as []";
        tile-bottom-half = [ "<Super>KP_2" ];
        tile-bottom-half-ignore-ta = "@as []";
        tile-bottomleft-quarter = [ "<Super>KP_1" ];
        tile-bottomleft-quarter-ignore-ta = "@as []";
        tile-bottomright-quarter = [ "<Super>KP_3" ];
        tile-bottomright-quarter-ignore-ta = "@as []";
        tile-edit-mode = "@as []";
        tile-left-half = [ "<Super>Left" "<Super>KP_4" ];
        tile-left-half-ignore-ta = "@as []";
        tile-maximize = [ "<Super>Up" "<Super>KP_5" ];
        tile-maximize-horizontally = "@as []";
        tile-maximize-vertically = "@as []";
        tile-right-half = [ "<Super>Right" "<Super>KP_6" ];
        tile-right-half-ignore-ta = "@as []";
        tile-top-half = [ "<Super>KP_8" ];
        tile-top-half-ignore-ta = "@as []";
        tile-topleft-quarter = [ "<Super>KP_7" ];
        tile-topleft-quarter-ignore-ta = "@as []";
        tile-topright-quarter = [ "<Super>KP_9" ];
        tile-topright-quarter-ignore-ta = "@as []";
        tiling-popup-all-workspace = false;
        toggle-always-on-top = "@as []";
        toggle-tiling-popup = "@as []";
      };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Nordic-bluish-accent";
    };

    "org/gnome/shell/extensions/vitals" = {
      hide-icons = false;
      menu-centered = false;
      use-higher-precision = true;
    };

    "org/gnome/shell/extensions/gsconnect/device/44912cba_4e5a_4ffd_a358_ba5dd18ebe27org/gnome/shell/extensions/gsconnect/device/44912cba_4e5a_4ffd_a358_ba5dd18ebe27" = {
      certificate-pem = ''
        -----BEGIN CERTIFICATE-----\nMIIBkzCCATmgAwIBAgIBATAKBggqhkjOPQQDBDBTMS0wKwYDVQQDDCQ0NDkxMmNi\nYV80ZTVhXzRmZmRfYTM1OF9iYTVkZDE4ZWJlMjcxFDASBgNVBAsMC0tERSBDb25u\nZWN0MQwwCgYDVQQKDANLREUwHhcNMjMwMzIxMDMwMDAwWhcNMzMwMzIxMDMwMDAw\nWjBTMS0wKwYDVQQDDCQ0NDkxMmNiYV80ZTVhXzRmZmRfYTM1OF9iYTVkZDE4ZWJl\nMjcxFDASBgNVBAsMC0tERSBDb25uZWN0MQwwCgYDVQQKDANLREUwWTATBgcqhkjO\nPQIBBggqhkjOPQMBBwNCAATe2oDgaASiCWkYHsCFKHzPUKABRJ7oa5xnKO59wy0G\nrS/hkI8Nz72mYn09qU03mF+WPW8tcttuNCbUozx9WftbMAoGCCqGSM49BAMEA0gA\nMEUCIQDUnveAz1AgasaRTGm2PDy3/vSCmAxG65aXBBkPJ+Wl5gIgBK/Nej0NPecJ\nnXuAM2e/ZHoCDdgIXL93jSzRBwVFT/Y=\n-----END CERTIFICATE-----\n
      '';
      incoming-capabilities = [ "kdeconnect.battery" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.contacts.request_all_uids_timestamps" "kdeconnect.contacts.request_vcards_by_uid" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.action" "kdeconnect.notification.reply" "kdeconnect.notification.request" "kdeconnect.ping" "kdeconnect.runcommand" "kdeconnect.sftp.request" "kdeconnect.share.request" "kdeconnect.share.request.update" "kdeconnect.sms.request" "kdeconnect.sms.request_attachment" "kdeconnect.sms.request_conversation" "kdeconnect.sms.request_conversations" "kdeconnect.systemvolume" "kdeconnect.telephony.request" "kdeconnect.telephony.request_mute" ];
      last-connection = "lan://192.168.1.6:1716";
      name = "Galaxy Note8";
      outgoing-capabilities = [ "kdeconnect.battery" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report" "kdeconnect.contacts.response_uids_timestamps" "kdeconnect.contacts.response_vcards" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.request" "kdeconnect.ping" "kdeconnect.presenter" "kdeconnect.runcommand.request" "kdeconnect.sftp" "kdeconnect.share.request" "kdeconnect.sms.attachment_file" "kdeconnect.sms.messages" "kdeconnect.systemvolume.request" "kdeconnect.telephony" ];
      paired = true;
      supported-plugins = [ "battery" "clipboard" "connectivity_report" "contacts" "findmyphone" "mousepad" "mpris" "notification" "ping" "presenter" "runcommand" "sftp" "share" "sms" "systemvolume" "telephony" ];
      type = "phone";
    };
  };

  #     "org/gnome/settings-daemon/plugins/color" = {
  #     night-light-enabled=true;
  # night-light-schedule-automatic=false;
  # night-light-schedule-from=19.499999999999972;
  # night-light-schedule-to=7.0;
  #     };

  # "org/gnome/shell/extensions/dash-to-dock" = {
  #   click-action = "skip";
  #   disable-overview-on-startup = true;
  #   dock-position = "LEFT";
  #   hot-keys = true;
  #   scroll-action = "cycle-windows";
  #   show-trash = false;
  # };

  # "org/gnome/shell/extensions/emoji-copy" = {
  #   always-show = false;
  #   emoji-keybind = [ "<Primary><Alt>e" ];
  # };

  # "org/gnome/shell/extensions/just-perfection" = {
  #   # panel-button-padding-size = mkInt32 5;
  #   panel-indicator-padding-size = mkInt32 3;
  #   #startup-status = mkInt32 0;
  #   window-demands-attention-focus = true;
  #   workspaces-in-app-grid = false;
  # };

  # "org/gnome/shell/extensions/wireless-hid" = {
  #   panel-box-index = mkInt32 4;
  # };

  # "org/gnome/shell/extensions/workspace-switcher-manager" = {
  #   active-show-ws-name = true;
  #   active-show-app-name = false;
  #   inactive-show-ws-name = true;
  #   inactive-show-app-name = false;
  # };

  # "org/gtk/gtk4/Settings/FileChooser" = {
  #   clock-format = "24h";
  # };

  # "org/gtk/gtk4/settings/file-chooser" = {
  #   show-hidden = false;
  #   show-size-column = true;
  #   show-type-column = true;
  #   sort-column = "name";
  #   sort-directories-first = true;
  #   sort-order = "ascending";
  #   type-format = "category";
  #   view-type = "list";
  # };

  # "org/gtk/Settings/FileChooser" = {
  #   clock-format = "24h";
  # };

  # "org/gtk/settings/file-chooser" = {
  #   show-hidden = false;
  #   show-size-column = true;
  #   show-type-column = true;
  #   sort-column = "name";
  #   sort-directories-first = true;
  #   sort-order = "ascending";
  #   type-format = "category";
  # };
}
