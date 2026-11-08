{
  desktop = {
    # Active desktop theme
    # options: catppuccin-mocha | catppuccin-macchiato | catppuccin-frappe | catppuccin-latte | dracula | nord | gruvbox-dark | tokyo-night | kanagawa-wave | doom | solarized | rose-pine | cyberpunk
    theme.name = "catppuccin-mocha";

    # Accent color role
    # options: red | orange | yellow | green | teal | cyan | blue | purple | pink
    theme.accent = "blue";

    # Modifier key for shortcuts (Mac Command key)
    # options: Super | Alt
    modifierKey = "Super";

    # Wallpaper directory or image path
    wallpaper.directory = "/home/juca/Pictures/Wallpapers";

    # Monitor configuration list
    monitors = [
      {
        name = "eDP-1";
        width = 1366;
        height = 768;
        refresh = 60;
        primary = true;
      }
    ];
  };

  # CLI programs to install by name
  my.apps.cli = [
    "direnv"
    "nix-direnv"
    "nil"
    "nh"
    "libva-utils"
    "intel-gpu-tools"
    "scrcpy"
  ];

  # GUI programs to install by name
  my.apps.gui = [ ];

  system.programs = {
    browsers = {
      chromium = {
        enable = true;
        version = "vivaldi";
      };
      psd.enable = false;
    };
    multimedia.mpv.profile = "low-ram";
  };

  programs.antigravity-cli.enable = true;
}
