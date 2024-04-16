_: {
  services = {
    picom = {
      enable = true;
      backend = "glx";
      shadow = true;
      shadowExclude = [
        "_GTK_FRAME_EXTENTS@:c"
      ];
      fade = true;
      fadeDelta = 5;
      inactiveOpacity = 0.75;
      settings = {
        blur = {
          # method = "dual_kawase";
          size = 24;
          strenght = 12;
          deviation = 5.0;
          backround-exclude = [
            "window_type = 'dock'"
            "window_type = 'desktop'"
            "_GTK_FRAME_EXTENTS@:c"
          ];
        };
        corner-radius = 8;
        rounded-corners-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
        ];
        use-ewmh-active-win = true;
        unredir-if-possible = true;
      };
      vSync = false;
      extraArgs = [
        "--legacy-backends"
        "--use-damage"
      ];
    };
  };
}
