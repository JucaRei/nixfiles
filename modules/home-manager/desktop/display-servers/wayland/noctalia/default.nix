{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;
  cfg = config.desktop.wayland.noctalia;
  isNoctalia = config.desktop.display-servers.backend == "wayland" && config.desktop.wayland.shell == "noctalia";
  tomlFormat = pkgs.formats.toml { };

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

  noctaliaWindowSwitcher = pkgs.writeShellScriptBin "noctalia-window-switcher" ''
    ${pkgs.noctalia}/bin/noctalia msg window-switcher
  '';

  noctaliaSessionLock = pkgs.writeShellScriptBin "noctalia-session-lock" ''
    ${pkgs.noctalia}/bin/noctalia msg session lock
  '';

  noctaliaSessionSuspend = pkgs.writeShellScriptBin "noctalia-session-suspend" ''
    ${pkgs.noctalia}/bin/noctalia msg session suspend
  '';

  noctaliaScreenshotFull = pkgs.writeShellScriptBin "noctalia-screenshot-full" ''
    ${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen
  '';

  noctaliaScreenshotRegion = pkgs.writeShellScriptBin "noctalia-screenshot-region" ''
    ${pkgs.noctalia}/bin/noctalia msg screenshot-region
  '';

  noctaliaScreenshotPick = pkgs.writeShellScriptBin "noctalia-screenshot-pick" ''
    ${pkgs.noctalia}/bin/noctalia msg screenshot-fullscreen pick
  '';

  noctaliaNightlightToggle = pkgs.writeShellScriptBin "noctalia-nightlight-toggle" ''
    ${pkgs.noctalia}/bin/noctalia msg nightlight-toggle
  '';

  noctaliaCaffeineToggle = pkgs.writeShellScriptBin "noctalia-caffeine-toggle" ''
    ${pkgs.noctalia}/bin/noctalia msg caffeine-toggle
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

  # Configuração declarativa base do Noctalia v5+ (Rice Catppuccin Mocha)
  defaultSettings = {
    theme = {
      mode = "dark";
      source = "builtin";
      builtin = "Catppuccin";
    };

    shell = {
      font_family = "Inter";
      button_borders = true;
      card_borders = true;
      input_borders = true;
      popup_borders = true;
      popup_shadows = true;
      time_format = "{:%H:%M:%S}";
      date_format = "%A, %d de %B";

      animation = {
        enabled = true;
        speed = 1.2;
      };

      launcher = {
        categories = true;
        sort_by_usage = true;
        compact = false;
        show_icons = true;
      };

      panel = {
        shadow = false;
        borders = true;
        transparency_mode = "solid";
        floating_layer = "overlay";
      };

      screenshot = {
        save_to_file = true;
        copy_to_clipboard = true;
        freeze_screen = true;
        directory = "~/Pictures/Screenshots";
      };
    };

    bar = {
      order = [ "default" ];
      default = {
        position = "top";
        enabled = true;
        thickness = 34;
        background_opacity = 0.88;
        radius = 12;
        margin_edge = 6;
        margin_ends = 12;
        padding = 10;
        widget_spacing = 6;
        shadow = false;
        contact_shadow = false;
        layer = "top";
        reserve_space = true;

        capsule = true;
        capsule_fill = "surface_variant";
        capsule_opacity = 0.95;
        capsule_thickness = 0.80;
        capsule_radius = 8.0;

        start = [
          "launcher"
          "workspaces"
          "mango_layout"
          "active_window"
        ];

        center = [
          "clock"
          "media"
        ];

        end = [
          "tray"
          "network"
          "bluetooth"
          "caffeine"
          "nightlight"
          "prponkshe/mango-displays:bar"
          "blackbartblues/keymap:widget"
          "noctalia/notes:notes"
          "noctalia/wallhaven:wallhaven"
          "volume"
          "battery"
          "session"
        ];
      };
    };

    plugins = {
      enabled = [
        "blackbartblues/keymap"
        "prponkshe/mango-displays"
        "noctalia/wallhaven"
        "noctalia/notes"
      ];
    };

    widget = {
      active_window = {
        icon_size = 14.0;
        max_length = 260.0;
        min_length = 60.0;
        title_scroll = "none";
      };

      mango_layout = {
        type = "custom_button";
        glyph = "layout-dashboard";
        tooltip = "MangoWM Tiling Layout (Clique: Menu de Seleção | Dir/Scroll: Alternar)";
        actions = {
          left = "exec mango-layout-picker";
          right = "exec mmsg dispatch switch_layout";
          middle = "exec mmsg dispatch switch_layout";
          scroll_up = "exec mmsg dispatch switch_layout";
          scroll_down = "exec mmsg dispatch switch_layout";
        };
      };

      clock = {
        format = "{:%H:%M:%S}";
        actions = {
          left = "panel-toggle control-center calendar";
        };
      };

      media = {
        art_size = 16.0;
        max_length = 220.0;
        min_length = 80.0;
      };

      tray = {
        hide_passive = false;
        drawer = false;
        match_adjacent_spacing = true;
      };
    };

    osd = {
      enabled = true;
      position = "top_center";
      border = true;
      scale = 1.0;
      kinds = {
        brightness = true;
        keyboard_backlight = true;
        volume = true;
        volume_input = true;
        volume_output = true;
        wifi = true;
        bluetooth = true;
        media = true;
        power_profile = true;
        nightlight = true;
        caffeine = true;
      };
    };

    nightlight = {
      enabled = false;
      force = false;
      temperature_day = 6500;
      temperature_night = 4000;
    };

    control_center = {
      show_session_button = true;
      show_shortcut_labels = true;
      shortcuts = [
        { type = "wifi"; }
        { type = "bluetooth"; }
        { type = "caffeine"; }
        { type = "nightlight"; }
        { type = "notification"; }
        { type = "power_profile"; }
      ];
    };

    brightness = {
      minimum_brightness = 0.0;
      enable_ddcutil = false;
    };

    system = {
      monitor = {
        enabled = true;
        cpu_poll_seconds = 2.0;
        memory_poll_seconds = 2.0;
        network_poll_seconds = 3.0;
      };
    };

    weather = {
      enabled = true;
      effects = true;
      refresh_minutes = 10;
      unit = "metric";
    };

    wallpaper = {
      enabled = true;
      fill_mode = "crop";
    };
  };
in
{
  options.desktop.wayland.noctalia = {
    enable = mkOption {
      type = bool;
      default = isNoctalia;
      description = "Habilitar Noctalia Shell integrado para ambientes Wayland com tema Catppuccin Mocha";
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "Configurações declarativas para o Noctalia Desktop Shell (v5+) em config.toml";
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
      noctaliaWindowSwitcher
      noctaliaSessionLock
      noctaliaSessionSuspend
      noctaliaScreenshotFull
      noctaliaScreenshotRegion
      noctaliaScreenshotPick
      noctaliaNightlightToggle
      noctaliaCaffeineToggle
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
      "noctalia/config.toml".source =
        tomlFormat.generate "config.toml" (lib.recursiveUpdate defaultSettings cfg.settings);
      "noctalia/palettes/CatppuccinMocha.json".text = builtins.toJSON catppuccinColors;
    };
  };
}
