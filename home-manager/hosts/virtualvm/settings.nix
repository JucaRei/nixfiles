{
  desktop = {
    # Active desktop theme
    # options: catppuccin-mocha | catppuccin-macchiato | catppuccin-frappe | catppuccin-latte | dracula | nord | gruvbox-dark | tokyo-night | kanagawa-wave | doom | solarized | rose-pine | cyberpunk
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
  };

  # CLI programs to install by name
  my.apps.cli = [ ];

  # GUI programs to install by name
  my.apps.gui = [ ];

  system = {
    programs = {
      browsers = {
        default = "firefox";
        firefox.enable = true;
      };
      terminal = {
        enable = true;
        name = "alacritty";
      };
      console = {
        eza.enable = true;
        bat.enable = true;
      };
      shells.enable = true;
    };
    services.podman = {
      enable = true;
      autoPrune.enable = true;
    };
  };
}
