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
      gnomeExtensions.bluetooth-quick-connect
      gnome-extension-manager
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
        "virt-manager.desktop"
        "org.gnome.nautilus.desktop"
        # "emacs.desktop"
        # "com.obsproject.studio.desktop"
        # "plexmediaplayer.desktop"
        # "smartcode-stremio.desktop"
        # "discord.desktop"
        # "steam.desktop"
        # "retroarch.desktop"
        # "com.parsecgaming.parsec.desktop"
        # "org.remmina.remmina.desktop"
        # "blueman-manager.desktop"
        # "pavucontrol.desktop"
      ];
      disable-user-extensions = false;
      enabled-extensions = [
        "trayiconsreloaded@selfmade.pl"
        "blur-my-shell@aunetx"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "dash-to-panel@jderose9.github.com"
        "just-perfection-desktop@just-perfection"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        "horizontal-workspace-indicator@tty2.io"
        "bluetooth-quick-connect@bjarosze.gmail.com"
        "battery-indicator@jgotti.org"
        "gsconnect@andyholmes.github.io"
        "pip-on-top@rafostar.github.com"
        "forge@jmmaranan.com"
        # "dash-to-dock@micxgx.gmail.com"           # Alternative Dash-to-Panel
        # "fullscreen-avoider@noobsai.github.com"   # Dash-to-Panel Incompatable
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
      # gtk-theme = "adwaita-dark";
      show-battery-percentage = true;
    };
    # "org/gnome/desktop/session" = {               # Not Working
    #   idle-delay = "uint32 900";
    # };
    "org/gnome/desktop/privacy" = {
      remember-recent-files = true;
      # Remember file history for the last 30 days
      recent-files-max-age = 30;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
      # Auto delete after 30 days
      old-files-age = uint32 30;
      report-technical-problems = "false";
    };
    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      action-right-click-titlebar = "toggle-maximize";
      action-middle-click-titlebar = "minimize";
      resize-with-right-button = true;
      mouse-button-modifier = "<super>";
      button-layout = ":minimize,close";
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

    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
      center-new-windows = true;
      edge-tiling = false; # Tiling
    };
    "org/gnome/mutter/keybindings" = {
      #toggle-tiled-left = ["<super>left"];         # Floating
      #toggle-tiled-right = ["<super>right"];
      toggle-tiled-left = [ "@as []" ]; # Tiling
      toggle-tiled-right = [ "@as []" ];
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      # Enable numlock by default
      numlock-state = true;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "areas";
      natural-scroll = false;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      # Disable auto suspend when charging
      sleep-interactive-ac-type = "nothing";
      # Dim screen on inactivity
      idle-dim = false;
      # Auto suspend after 30 minutes of inactivity if on battery power
      sleep-inactive-battery-type = "suspend";
      sleep-inactive-battery-timeout = 1800;
      # Auto power saver on low battery
      power-saver-profile-on-low-battery = true;
    };
    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
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
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<super>t";
      command = "emacs";
      name = "open-editor";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<super>e";
      command = "nautilus";
      name = "open-file-browser";
    };

    "org/gnome/shell/extension/dash-to-panel" = {
      # Set Manually
      panel-position = ''{"0":"top","1":"top"}'';
      panel-sizes = ''{"0":24,"1":24}'';
      panel-element-positions-monitors-sync = true;
      appicon-margin = 0;
      appicon-padding = 4;
      dot-position = "top";
      dot-style-focused = "solid";
      dot-style-unfocused = "dots";
      animate-appicon-hover = true;
      animate-appicon-hover-animation-travel = "{'simple': 0.14999999999999999, 'ripple': 0.40000000000000002, 'plank': 0.0}";
      isolate-monitors = true;
    };
    "org/gnome/shell/extensions/just-perfection" = {
      theme = true;
      activities-button = false;
      app-menu = false;
      clock-menu-position = 1;
      clock-menu-position-offset = 7;
    };
    "org/gnome/shell/extensions/caffeine" = {
      enable-fullscreen = true;
      restore-state = true;
      show-indicator = true;
      show-notification = false;
    };
    "org/gnome/shell/extensions/blur-my-shell" = {
      brightness = 0.9;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      customize = true;
      sigma = 0;
    };
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      customize = true;
      sigma = 0;
    };
    "org/gnome/shell/extensions/horizontal-workspace-indicator" = {
      widget-position = "left";
      widget-orientation = "horizontal";
      icons-style = "circles";
    };
    "org/gnome/shell/extensions/bluetooth-quick-connect" = {
      show-battery-icon-on = true;
      show-battery-value-on = true;
    };
    "org/gnome/shell/extensions/pip-on-top" = {
      stick = true;
    };
    "org/gnome/shell/extensions/forge" = {
      window-gap-size = 8;
      dnd-center-layout = "stacked";
    };
    "org/gnome/shell/extensions/forge/keybindings" = {
      # Set Manually
      focus-border-toggle = true;
      float-always-on-top-enabled = true;
      window-focus-up = [ "<super>up" ];
      window-focus-down = [ "<super>down" ];
      window-focus-left = [ "<super>left" ];
      window-focus-right = [ "<super>right" ];
      window-move-up = [ "<shift><super>up" ];
      window-move-down = [ "<shift><super>down" ];
      window-move-left = [ "<shift><super>left" ];
      window-move-right = [ "<shift><super>right" ];
      window-swap-last-active = [ "@as []" ];
      window-toggle-float = [ "<shift><super>f" ];
    };
    # "org/gnome/shell/extensions/dash-to-dock" = { # If Dock Preferred
    #   multi-monitor = true;
    #   dock-fixed = true;
    #   dash-max-icon-size = 16;
    #   custom-theme-shrink = true;
    #   transparency-mode = "fixed";
    #   background-opacity = 0.0;
    #   show-apps-at-top = true;
    #   show-trash = true;
    #   hot-keys = false;
    #   click-action = "previews";
    #   scroll-action = "cycle-windows";
    # };
  };
}
