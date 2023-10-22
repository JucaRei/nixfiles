_: {
  # Picom, my window compositor with fancy effects
  #
  # Notes on writing exclude rules:
  #
  #   class_g looks up index 1 in WM_CLASS value for an application
  #   class_i looks up index 0
  #
  #   To find the value for a specific application, use `xprop` at the
  #   terminal and then click on a window of the application in question
  #
  services.picom = {
    enable = true;
    settings = {
      # General Settings #
      backend = "glx";
      vsync = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      unredir-if-possible = true;
      log-level = "warn";
      detect-client-leader = true;
      glx-copy-from-front = false;


      # Corners #
      corner-radius = 10;
      rounded-corners-exclude = [
        "window_type = 'dropdown_menu'"
        "window_type = 'popup_menu'"
        "window_type = 'popup'"
        "class_g = 'Polybar'"
        "class_g = 'Rofi'"
        "class_g = 'mpv'"
      ];

      # Shadows #
      shadow = false;
      shadow-radius = 18;
      #shadow-opacity = .75
      shadow-offset-x = "-25";
      shadow-offset-y = "-22";
      #shadow-color = "#000000";
      shadow-exclude = [
        "name = 'Notification'"
        "class_g ?= 'Notify-osd'"
        "class_g = 'slop'"
        "class_g = 'Polybar'"
        "class_g = 'Rofi'"
        "_GTK_FRAME_EXTENTS@:c"
      ];

      # Fading #
      fading = true;
      fade-delta = 2;
      fade-in-step = "0.01";
      fade-out-step = "0.01";
      fade-exclude = [
        "WM_CLASS@:s *= 'screenkey'"
        "class_g = 'slop'"
        "class_g = 'bspwm'"
      ];

      # Transparency / Opacity #
      inactive-opacity = "1.0";
      inactive-opacity-override = false;
      active-opacity = "1.0";

      # Dim inactive windows. (0.0 - 1.0, defaults to 0.0)
      inactive-dim = "1.0";
      focus-exclude = [
        "class_g = 'slop'"
      ];
      opacity-rule = [
        "100:class_g    = 'Polybar'"
        "100:class_g    = 'TelegramDesktop'"
        "100:class_g    = 'firefox'"
        # "90:!focused",
      ];

      # blur #
      blur-method = "dual_kawase";
      blur-strength = 3;
      blur-background-exclude = [
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
        "class_g *= 'wemeetapp'"
        "class_g *= 'slop'"
        "class_g *= 'Gromit-mpx'"
      ];

      # animations #
      animations = true;
      #change animation speed of windows in current tag e.g open window in current tag
      animation-stiffness-in-tag = 100;
      #change animation speed of windows when tag changes
      animation-stiffness-tag-change = 90.0;
      animation-window-mass = 0.5;
      animation-dampening = 12;
      animation-clamping = false;
      animation-for-open-window = "zoom"; #open window
      animation-for-unmap-window = "slide-down"; #minimize or close window
      animation-for-transient-window = "zoom"; #popup windows
      #set animation for windows being transitioned out while changings tags
      animation-for-prev-tag = "minimize";
      #enables fading for windows being transitioned out while changings tags
      enable-fading-prev-tag = true;

      #set animation for windows being transitioned in while changings tags
      animation-for-next-tag = "slide-in-center";
      #enables fading for windows being transitioned in while changings tags
      enable-fading-next-tag = true;
      animation-exclude = [
        "class_g = 'fcitx'"
        "WM_CLASS@:s *= 'screenkey'"
      ];

      wintypes = {
        "tooltip" = { fade = true; shadow = false; focus = true; full-shadow = false; };
        "fullscreen" = { fade = true; shadow = false; focus = true; };
      };
    };
  };
}
