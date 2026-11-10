{
  desktop = {
    # Active desktop theme
    # options: run  ./scripts/nx themes
    theme.name = "catppuccin-mocha";

    # Accent color role
    # options: red | orange | yellow | green | teal | cyan | blue | purple | pink
    theme.accent = "blue";

    # Modifier key for shortcuts
    # options: Super | Alt
    modifierKey = "Alt";

    # Wallpaper directory or image path
    wallpaper.directory = "/home/juca/Pictures/Wallpapers";

    # Monitor configuration list
    monitors = [
      {
        name = "HDMI-1-0";
        width = 1920;
        height = 1080;
        refresh = 60;
        x = 0;
        y = 0;
        primary = true;
      }
      {
        name = "eDP-1";
        width = 1920;
        height = 1080;
        refresh = 60;
        x = 1920;
        y = 0;
        primary = false;
      }
    ];
  };

  # CLI programs to install by name
  my.apps.cli = [
    "intel-media-driver"
    "scrcpy"
    "solaar"
  ];

  # GUI programs to install by name (wrapped with nixGL)
  my.apps.gui = [
    "mdhero"
    "antigravity-app"
  ];
}
