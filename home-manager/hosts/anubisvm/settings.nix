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
    modifierKey = "Super";

    # Wallpaper directory or image path
    wallpaper.directory = "/home/juca/Pictures/Wallpapers";

    # Monitor configuration list
    monitors = [
      {
        name = "Virtual-1";
        width = 1920;
        height = 1080;
        refresh = 60;
        primary = true;
      }
    ];

    bspwm = {
      enable = true;
      sxhkd.enable = true;
      polybar.enable = true;
      packages.enable = true;
    };
  };

  # CLI programs to install by name
  my.apps.cli = [ ];

  # GUI programs to install by name
  my.apps.gui = [ ];

  system.programs = {
    console = {
      eza.enable = true;
      bat.enable = true;
    };
    shells.enable = true;
  };
}
