{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;
  cfg = config.desktop.wayland;
  isNoctalia = config.desktop.display-servers.backend == "wayland" && cfg.shell == "noctalia";

  # Scripts de controle via IPC nativo do Noctalia (v5+)
  noctaliaLauncher = pkgs.writeShellScriptBin "noctalia-launcher" ''
    ${pkgs.noctalia}/bin/noctalia msg panel-toggle launcher
  '';

  noctaliaCliphist = pkgs.writeShellScriptBin "noctalia-cliphist" ''
    ${pkgs.noctalia}/bin/noctalia msg panel-toggle clipboard
  '';

  noctaliaControlCenter = pkgs.writeShellScriptBin "noctalia-control-center" ''
    ${pkgs.noctalia}/bin/noctalia msg panel-toggle control-center
  '';

  noctaliaSessionMenu = pkgs.writeShellScriptBin "noctalia-session-menu" ''
    ${pkgs.noctalia}/bin/noctalia msg panel-toggle session
  '';

  noctaliaWallpaper = pkgs.writeShellScriptBin "noctalia-wallpaper" ''
    ${pkgs.noctalia}/bin/noctalia msg panel-toggle wallpaper
  '';

  # Paleta Catppuccin Mocha completa para o Noctalia v5+
  catppuccinColors = {
    mPrimary = "#cba6f7"; # Mauve
    mOnPrimary = "#11111b"; # Crust
    mSecondary = "#fab387"; # Peach
    mOnSecondary = "#11111b";
    mTertiary = "#94e2d5"; # Teal
    mOnTertiary = "#11111b";
    mError = "#f38ba8"; # Red
    mOnError = "#11111b";
    mSurface = "#1e1e2e"; # Base
    mOnSurface = "#cdd6f4"; # Text
    mSurfaceVariant = "#313244"; # Surface0
    mOnSurfaceVariant = "#a6adc8"; # Subtext0
    mOutline = "#45475a"; # Surface1
    mShadow = "#11111b";
    mHover = "#89b4fa"; # Blue
    mOnHover = "#11111b";
  };

  # Configuração declarativa TOML do Noctalia v5+ (baseada na documentação oficial)
  noctaliaTomlConfig = ''
    # ============================================================================
    # Noctalia Desktop Shell Configuration (v5+) - Rice Catppuccin Mocha
    # ============================================================================

    [theme]
    mode = "dark"
    source = "builtin"
    builtin = "Catppuccin"

    [shell]
    font_family = "Inter"
    button_borders = true
    card_borders = true
    input_borders = true
    popup_borders = true
    popup_shadows = true
    time_format = "{:%H:%M:%S}"
    date_format = "%A, %d de %B"

    [shell.animation]
    enabled = true
    speed = 1.2

    [shell.launcher]
    categories = true
    sort_by_usage = true
    compact = false
    show_icons = true

    [shell.panel]
    shadow = false
    borders = true
    transparency_mode = "solid"
    floating_layer = "overlay"

    [bar]
    order = [ "default" ]

    [bar.default]
    position = "top"
    enabled = true
    thickness = 34
    background_opacity = 0.88
    radius = 12
    margin_edge = 6
    margin_ends = 12
    padding = 10
    widget_spacing = 6
    shadow = false
    contact_shadow = false
    layer = "top"
    reserve_space = true

    # Estilo de cápsula (pill) para widgets
    capsule = true
    capsule_fill = "surface_variant"
    capsule_opacity = 0.95
    capsule_thickness = 0.80
    capsule_radius = 8.0

    # Layout de widgets na barra
    start = [
      "launcher",
      "workspaces",
      # "yuki/lunar-workspaces:lunar_workspaces",
      # "gambled23/mangowm-keymode:mangowm-keymode",
      "mango_layout",
      "active_window"
    ]

    center = [
      "clock",
      "media"
    ]

    end = [
      "tray",
      # "notifications",
      # "yuuto/calculator:bar",
      "clipboard",
      "network",
      "bluetooth",
      "brightness",
      "prponkshe/mango-displays:bar",
      "blackbartblues/keymap:widget",
      # "noctalia/timer:bar",
      "noctalia/notes:notes",
      "noctalia/wallhaven:wallhaven",
      "volume",
      "battery",
      # "control-center",
      "session",
    ]

    [plugins]
    enabled = [
      "blackbartblues/keymap",
      "prponkshe/mango-displays",
      # "gambled23/mangowm-keymode",
      # "yuki/lunar-workspaces",
      # "yuuto/calculator",
      "noctalia/wallhaven",
      # "noctalia/timer",
      "noctalia/notes"
    ]

    # [widget.workspaces]
    # style = "regular"
    # show_labels = true
    # label_source = "id"
    # pill_scale = 1.0
    # active_pill_size = 2.2
    # inactive_pill_size = 1.0
    # focused_color = "primary"
    # occupied_color = "secondary"
    # empty_color = "surface_variant"
    # urgent_color = "error"

    [widget.active_window]
    icon_size = 14.0
    max_length = 260.0
    min_length = 60.0
    title_scroll = "none"

    [widget.mango_layout]
    type = "custom_button"
    glyph = "layout-dashboard"
    tooltip = "MangoWM Tiling Layout (Clique: Menu de Seleção | Dir/Scroll: Alternar)"

    [widget.mango_layout.actions]
    left = "exec mango-layout-picker"
    right = "exec mmsg dispatch switch_layout"
    middle = "exec mmsg dispatch switch_layout"
    scroll_up = "exec mmsg dispatch switch_layout"
    scroll_down = "exec mmsg dispatch switch_layout"

    [widget.clock]
    format = "{:%H:%M:%S}"

    [widget.clock.actions]
    left = "panel-toggle control-center calendar"

    [widget.media]
    art_size = 16.0
    max_length = 220.0
    min_length = 80.0

    [widget.tray]
    hide_passive = false
    drawer = false
    match_adjacent_spacing = true

    [osd]
    enabled = true
    position = "top_center"
    border = true
    scale = 1.0

    [osd.kinds]
    brightness = true
    keyboard_backlight = true
    volume = true
    volume_input = true
    volume_output = true
    wifi = true
    bluetooth = true
    media = true
    power_profile = true
    nightlight = true

    [brightness]
    minimum_brightness = 0.0
    enable_ddcutil = false

    [system.monitor]
    enabled = true
    cpu_poll_seconds = 2.0
    memory_poll_seconds = 2.0
    network_poll_seconds = 3.0

    [location]
    auto_locate = true
    address = "São Paulo, Brazil"
    latitude = -23.6293
    longitude = -46.6351

    [weather]
    enabled = true
    effects = true
    refresh_minutes = 30
    unit = "metric"

    [wallpaper]
    enabled = true
    fill_mode = "crop"
  '';
in
{
  options.desktop.wayland.noctalia = {
    enable = mkOption {
      type = bool;
      default = isNoctalia;
      description = "Habilitar Noctalia Shell integrado para ambientes Wayland com tema Catppuccin Mocha";
    };
  };

  config = mkIf isNoctalia {
    home.packages = [
      pkgs.noctalia
      noctaliaLauncher
      noctaliaCliphist
      noctaliaControlCenter
      noctaliaSessionMenu
      noctaliaWallpaper
      pkgs.brightnessctl
      pkgs.wl-clipboard
      pkgs.cliphist
      pkgs.imagemagick
      pkgs.socat
      pkgs.wlr-randr
      pkgs.wdisplays
      pkgs.wl-mirror
    ];

    # Provisionamento declarativo de configuração TOML e paleta do Noctalia v5+
    xdg.configFile = {
      "noctalia/config.toml".text = noctaliaTomlConfig;
      "noctalia/palettes/CatppuccinMocha.json".text = builtins.toJSON catppuccinColors;
    };
  };
}
