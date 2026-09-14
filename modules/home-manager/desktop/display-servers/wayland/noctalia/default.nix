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

  # Scripts de controle via IPC nativo do Noctalia Shell
  noctaliaLauncher = pkgs.writeShellScriptBin "noctalia-launcher" ''
    noctalia-shell ipc call launcher toggle 2>/dev/null || \
      qs -c noctalia-shell ipc call launcher toggle 2>/dev/null || \
      ${pkgs.noctalia-shell}/bin/noctalia-shell &
  '';

  noctaliaCliphist = pkgs.writeShellScriptBin "noctalia-cliphist" ''
    noctalia-shell ipc call launcher clipboard 2>/dev/null || \
      qs -c noctalia-shell ipc call launcher clipboard 2>/dev/null
  '';

  noctaliaControlCenter = pkgs.writeShellScriptBin "noctalia-control-center" ''
    noctalia-shell ipc call controlCenter toggle 2>/dev/null || \
      qs -c noctalia-shell ipc call controlCenter toggle 2>/dev/null
  '';

  noctaliaSessionMenu = pkgs.writeShellScriptBin "noctalia-session-menu" ''
    noctalia-shell ipc call sessionMenu toggle 2>/dev/null || \
      qs -c noctalia-shell ipc call sessionMenu toggle 2>/dev/null
  '';

  noctaliaWallpaper = pkgs.writeShellScriptBin "noctalia-wallpaper" ''
    noctalia-shell ipc call wallpaper toggle 2>/dev/null || \
      qs -c noctalia-shell ipc call wallpaper toggle 2>/dev/null
  '';

  # Paleta Catppuccin Mocha completa para o Noctalia
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

  # Configurações ricas do Noctalia Shell (Barra flutuante, Dock, Widgets, Launcher, etc.)
  noctaliaSettings = {
    settingsVersion = 59;

    # Barra Superior Flutuante Moderna (Floating Pill)
    bar = {
      barType = "floating";
      position = "top";
      density = "comfortable";
      showOutline = false;
      showCapsule = true;
      capsuleOpacity = 0.95;
      capsuleColorKey = "none";
      widgetSpacing = 8;
      contentPadding = 4;
      fontScale = 1.0;
      enableExclusionZoneInset = false;
      backgroundOpacity = 0.88;
      marginVertical = 4;
      marginHorizontal = 8;
      frameRadius = 12;
      outerCorners = false;
      displayMode = "always_visible";

      widgets = {
        left = [
          { id = "Launcher"; }
          {
            id = "Workspace";
            followFocusedScreen = true;
            hideUnoccupied = false;
            labelMode = "index";
            showLabelsOnlyWhenOccupied = false;
            pillSize = 0.8;
            focusedColor = "primary";
            occupiedColor = "secondary";
            emptyColor = "surfaceVariant";
          }
          { id = "ActiveWindow"; }
        ];
        center = [
          { id = "Clock"; }
          { id = "MediaMini"; }
        ];
        right = [
          { id = "SystemMonitor"; }
          { id = "Tray"; }
          { id = "NotificationHistory"; }
          { id = "Battery"; }
          { id = "Brightness"; }
          { id = "Volume"; }
          { id = "ControlCenter"; }
        ];
      };

      mouseWheelAction = "none";
      rightClickAction = "controlCenter";
    };

    # Localização e Previsão do Tempo
    location = {
      name = "São Paulo, Brazil";
      autoLocate = true;
      weatherEnabled = true;
      weatherShowEffects = true;
      useFahrenheit = false;
      use12hourFormat = false;
      showCalendarEvents = true;
      showCalendarWeather = true;
      hideWeatherTimezone = false;
      hideWeatherCityName = false;
    };

    # Calendário com Cartão de Previsão do Tempo
    calendar = {
      cards = [
        { id = "calendar-header-card"; enabled = true; }
        { id = "calendar-month-card"; enabled = true; }
        { id = "weather-card"; enabled = true; }
      ];
    };

    # Aparência Geral e Efeitos (sem sombras intrusivas que cortam janelas)
    general = {
      scaleRatio = 1.0;
      radiusRatio = 1.0;
      animationSpeed = 1.2;
      animationDisabled = false;
      enableShadows = false;
      shadowOffsetX = 0;
      shadowOffsetY = 0;
      enableBlurBehind = true;
      clockStyle = "custom";
      clockFormat = "hh:mm";
      compactLockScreen = false;
      lockOnSuspend = true;
      showSessionButtonsOnLockScreen = true;
      allowPanelsOnScreenWithoutBar = true;
    };

    # Interface de Usuário e Tipografia
    ui = {
      fontDefault = "Inter";
      fontFixed = "JetBrainsMono Nerd Font";
      fontDefaultScale = 1.0;
      fontFixedScale = 1.0;
      tooltipsEnabled = true;
      scrollbarAlwaysVisible = true;
      panelBackgroundOpacity = 0.92;
      panelsAttachedToBar = true;
      settingsPanelMode = "attached";
    };

    # Esquema de Cores (Catppuccin Mocha Dark)
    colorSchemes = {
      predefinedScheme = "Catppuccin";
      darkMode = true;
      useWallpaperColors = false;
      generationMethod = "tonal-spot";
      syncGsettings = true;
      schedulingMode = "off";
    };

    # Dock Inferior Flutuante com Auto-Hide e Ícones Corretos
    dock = {
      enabled = true;
      position = "bottom";
      dockType = "floating";
      displayMode = "auto_hide";
      backgroundOpacity = 0.85;
      floatingRatio = 1.0;
      size = 1.0;
      onlySameOutput = true;
      pinnedStatic = true;
      colorizeIcons = false;
      showLauncherIcon = true;
      launcherPosition = "start";
      showDockIndicator = true;
      indicatorColor = "primary";
      pinnedApps = [
        "firefox.desktop"
        "vivaldi-stable.desktop"
        "thunar.desktop"
        "Alacritty.desktop"
        "antigravity-ide.desktop"
      ];
    };

    # Launcher de Aplicações
    appLauncher = {
      position = "center";
      viewMode = "grid";
      density = "comfortable";
      showCategories = true;
      sortByMostUsed = true;
      iconMode = "tabler";
      enableClipboardHistory = true;
      autoPasteClipboard = false;
      enableClipPreview = true;
      clipboardWrapText = true;
      terminalCommand = "alacritty -e";
      enableSettingsSearch = true;
      enableWindowsSearch = true;
      enableSessionSearch = true;
    };

    # Painel de Controle Rápido (Control Center)
    controlCenter = {
      position = "close_to_bar_button";
      shortcuts = {
        left = [
          { id = "Network"; }
          { id = "Bluetooth"; }
          { id = "WallpaperSelector"; }
          { id = "NoctaliaPerformance"; }
        ];
        right = [
          { id = "Notifications"; }
          { id = "PowerProfile"; }
          { id = "KeepAwake"; }
          { id = "NightLight"; }
        ];
      };
      cards = [
        { enabled = true; id = "profile-card"; }
        { enabled = true; id = "shortcuts-card"; }
        { enabled = true; id = "audio-card"; }
        { enabled = true; id = "brightness-card"; }
        { enabled = true; id = "weather-card"; }
        { enabled = true; id = "media-sysmon-card"; }
      ];
    };

    # Menu de Sessão / Energia
    sessionMenu = {
      position = "center";
      largeButtonsStyle = true;
      showHeader = true;
      showKeybinds = true;
      enableCountdown = false;
    };

    # Notificações
    notifications = {
      enabled = true;
      location = "top_right";
      density = "compact";
      backgroundOpacity = 0.92;
      clearDismissed = true;
      lowUrgencyDuration = 3;
      normalUrgencyDuration = 6;
      criticalUrgencyDuration = 10;
    };

    # OSD (Volume / Brilho)
    osd = {
      enabled = true;
      location = "top_right";
      autoHideMs = 2000;
      backgroundOpacity = 0.90;
    };

    # Áudio e Brilho
    audio = {
      volumeStep = 2;
      visualizerType = "linear";
    };

    brightness = {
      brightnessStep = 2;
      enforceMinimum = true;
    };

    # Papel de Parede
    wallpaper = {
      enabled = true;
      fillMode = "crop";
      solidColor = "#1e1e2e";
      setWallpaperOnAllMonitors = true;
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
  };

  config = mkIf isNoctalia {
    home.packages = [
      pkgs.noctalia-shell
      noctaliaLauncher
      noctaliaCliphist
      noctaliaControlCenter
      noctaliaSessionMenu
      noctaliaWallpaper
      pkgs.wlsunset
      pkgs.brightnessctl
      pkgs.wl-clipboard
      pkgs.cliphist
      pkgs.imagemagick
    ];

    # Provisionamento declarativo de temas e configurações do Noctalia Shell
    xdg.configFile = {
      "noctalia/settings.json".text = builtins.toJSON noctaliaSettings;
      "noctalia/colors.json".text = builtins.toJSON catppuccinColors;
    };
  };
}
