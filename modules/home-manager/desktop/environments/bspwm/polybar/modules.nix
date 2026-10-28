{
  lib,
  pkgs,
  colors,
  scripts,
  cfg ? {
    battery = "BAT0";
    adapter = "ADP1";
    encapsulation = "pill";
    tray = {
      enable = true;
    };
  },
  ...
}:
let
  rawEncap =
    if builtins.isAttrs (cfg.encapsulation or null) then
      cfg.encapsulation.default or "pill"
    else
      cfg.encapsulation or "pill";

  resolveColor =
    val: defaultVal:
    if val == null || val == "" then
      defaultVal
    else if lib.strings.hasPrefix "#" val then
      val
    else if colors ? ${val} then
      colors.${val}
    else
      defaultVal;

  customGlyphColor =
    if builtins.isAttrs (cfg.encapsulation or null) then
      resolveColor (cfg.encapsulation.colors.glyph or cfg.encapsulation.colors.default or null
      ) colors.pill
    else
      colors.pill;

  encapType =
    if rawEncap != "pill" then
      rawEncap
    else if (cfg.style or "") == "shapes" then
      "shapes"
    else
      "pill";

  # Mapeamento do tipo de encapsulamento para os respectivos glifos
  # pill: cápsulas arredondadas ( e )
  # shapes: blocos de pixel/malha ( e ) como no debian-bspwm-e300
  # slant: cortes diagonais paralelos ( e )
  # powerline: triângulos clássicos ( e )
  encapGlyphs = {
    pill = {
      left = "";
      right = "";
    };
    shapes = {
      left = "";
      right = "";
    };
    slant = {
      left = "";
      right = "";
    };
    powerline = {
      left = "";
      right = "";
    };
  };

  currentEncap = encapGlyphs.${encapType} or encapGlyphs.pill;

  colorList = [
    "pill"
    "pill-alt"
    "pill-active"
    "red"
    "orange"
    "yellow"
    "green"
    "teal"
    "cyan"
    "blue"
    "purple"
    "pink"
    "accent"
    "ice"
    "coral"
    "mint"
    "nord"
    "dark"
    "surface0"
    "surface1"
    "surface2"
    "shade1"
    "shade2"
    "shade3"
    "shade4"
    "shade5"
    "shade6"
    "shade7"
    "shade8"
  ];

  # Gerar dinamicamente módulos de encapsulamento coloridos (ex: shape-left-purple, shape-left-red, etc.)
  mkColoredEncapModules = lib.foldl' (
    acc: cName:
    let
      cVal = colors.${cName} or colors.pill;
    in
    acc
    // {
      "module/shape-left-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/shape-right-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/round-left-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/round-right-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/slant-left-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/slant-right-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/powerline-left-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/powerline-right-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/sp-${cName}" = {
        type = "custom/text";
        format = "<label>";
        format-background = cVal;
        label = " ";
        label-background = cVal;
      };
    }
  ) { } colorList;
in
{
  # --- Divisores & Espaçadores Elegantes (Estilo Waybar / Catppuccin) ---
  "module/sep" = {
    type = "custom/text";
    format = "<label>";
    label = "  %{F${colors.surface1}}│%{F-}  ";
  };

  "module/dots" = {
    type = "custom/text";
    format = "<label>";
    label = "  %{F${colors.surface1}}·%{F-}  ";
  };

  # --- Lançador de Aplicativos (Logo do Sistema Operacional com Cor Oficial Dinâmica) ---
  "module/launcher" = {
    type = "custom/script";
    exec = "${scripts.osLogoScript}";
    interval = 3600;
    format = "%{A1:${pkgs.rofi}/bin/rofi -show drun:}<label>%{A}";
    label = "%output%";
    label-font = 4;
    label-padding = 1;
    click-left = "${pkgs.rofi}/bin/rofi -show drun";
  };

  # --- Encapsulamento Dinâmico (Respeita desktop.bspwm.polybar.encapsulation: pill, shapes, slant, powerline) ---
  "module/encap-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}${currentEncap.left}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/encap-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}${currentEncap.right}%{T-}";
    label-foreground = customGlyphColor;
  };

  # Aliases clássicos de cápsula arredondada (pill)
  "module/round-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/round-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/bi" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/bd" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  # Módulos explícitos com glifos fixos (permite misturar estilos livremente na mesma barra)
  "module/pill-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/pill-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/shape-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/shape-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/shapes-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/shapes-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  # 3. Estilo Slant / Diagonal Paralelo ( e )
  "module/slant-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/slant-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  # Variações para baixo com direção alternada ( e )
  "module/slant-down-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/slant-down-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  # Variações com corte para cima ( e )
  "module/slant-up-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/slant-up-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/powerline-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  "module/powerline-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = customGlyphColor;
  };

  # --- Módulos de Transição Sombreada Estilo Shapes (debian-bspwm-e300 / adi1090x) ---
  # Lado esquerdo: transições com  (gleft) entre os blocos sombreados shade1 -> shade2 -> shade3...
  "module/left1" = {
    type = "custom/text";
    format = "<label>";
    format-background = colors.shade2;
    format-foreground = colors.shade1;
    label = "%{T5}%{T-}";
  };

  "module/left2" = {
    type = "custom/text";
    format = "<label>";
    format-background = colors.shade3;
    format-foreground = colors.shade2;
    label = "%{T5}%{T-}";
  };

  "module/left3" = {
    type = "custom/text";
    format = "<label>";
    format-background = colors.dark;
    format-foreground = colors.shade3;
    label = "%{T5}%{T-}";
  };

  "module/left4" = {
    type = "custom/text";
    format = "<label>";
    format-background = colors.dark;
    format-foreground = colors.shade4;
    label = "%{T5}%{T-}";
  };

  # Lado direito: transições com  (gright) fluindo do fundo para shade4 -> shade3 -> shade2 -> shade1
  "module/right1" = {
    type = "custom/text";
    format = "<label>";
    format-background = colors.shade2;
    format-foreground = colors.shade1;
    label = "%{T5}%{T-}";
  };

  "module/right2" = {
    type = "custom/text";
    format = "<label>";
    format-background = colors.shade3;
    format-foreground = colors.shade2;
    label = "%{T5}%{T-}";
  };

  "module/right3" = {
    type = "custom/text";
    format = "<label>";
    format-background = colors.shade4;
    format-foreground = colors.shade3;
    label = "%{T5}%{T-}";
  };

  "module/right4" = {
    type = "custom/text";
    format = "<label>";
    format-background = colors.dark;
    format-foreground = colors.shade4;
    label = "%{T5}%{T-}";
  };

  "module/sp" = {
    type = "custom/text";
    format = "<label>";
    label = " ";
  };

  "module/sp-pill" = {
    type = "custom/text";
    format = "<label>";
    format-background = customGlyphColor;
    label = " ";
    label-background = customGlyphColor;
  };

  "module/space" = {
    type = "custom/text";
    format = "<label>";
    label = " ";
  };

  # --- Workspaces do BSPWM (Badges Modernos Estilo Waybar) ---
  "module/bspwm" = {
    type = "internal/bspwm";
    pin-workspaces = true;
    enable-click = true;
    enable-scroll = true;
    reverse-scroll = false;
    inline-mode = false;
    fuzzy-match = true;

    # Mapeamento dos workspaces de 1 a 10 em numerais Kanji (Japanese numerals)
    ws-icon-0 = "1;一";
    ws-icon-1 = "2;二";
    ws-icon-2 = "3;三";
    ws-icon-3 = "4;四";
    ws-icon-4 = "5;五";
    ws-icon-5 = "6;六";
    ws-icon-6 = "7;七";
    ws-icon-7 = "8;八";
    ws-icon-8 = "9;九";
    ws-icon-9 = "0;十";
    ws-icon-10 = "10;十";
    ws-icon-default = "%name%";

    format = "<label-state>";

    label-focused = "%icon%";
    label-focused-foreground = colors.base;
    label-focused-background = colors.blue;
    label-focused-padding = 1;
    label-focused-margin = 1;

    label-occupied = "%icon%";
    label-occupied-foreground = colors.text;
    label-occupied-padding = 1;
    label-occupied-margin = 1;

    label-urgent = "%icon%";
    label-urgent-foreground = colors.base;
    label-urgent-background = colors.red;
    label-urgent-padding = 1;
    label-urgent-margin = 1;

    label-empty = "%icon%";
    label-empty-foreground = colors.surface1;
    label-empty-padding = 1;
    label-empty-margin = 1;
  };

  # --- Título da Janela Ativa (Interativo: Clique para Minimizar, Meio para Fechar, Direito para Fullscreen) ---
  "module/xwindow" = {
    type = "internal/xwindow";
    format = "%{A1:${pkgs.bspwm}/bin/bspc node -g hidden=on:}%{A2:${pkgs.bspwm}/bin/bspc node -c:}%{A3:${pkgs.bspwm}/bin/bspc node -t ~fullscreen:}<label>%{A}%{A}%{A}";
    format-prefix = "󰣆 ";
    format-prefix-foreground = colors.sapphire;
    label = "%title:0:30:...%";
    label-foreground = colors.subtext0;
    label-padding = 1;
    label-empty = "Área de Trabalho";
    label-empty-foreground = colors.surface2;
    label-empty-padding = 1;
  };

  # --- Janelas Minimizadas / Ocultas na Polybar (Dinâmica via script) ---
  "module/minimized" = {
    type = "custom/script";
    exec = "${scripts.minimizedScript}";
    interval = 1;
    format = "%{A1:${pkgs.bspwm}/bin/bspc node any.hidden.local -g hidden=off -f:}%{A3:${scripts.restoreMenuScript}:}<label>%{A}%{A}";
    format-background = colors.transparent;
    format-foreground = colors.peach;
    label = "%output%";
    click-left = "${pkgs.bspwm}/bin/bspc node any.hidden.local -g hidden=off -f";
    click-right = "${scripts.restoreMenuScript}";
  };

  # --- Taskbar Interativa de Janelas (Polywins - Ícones e Gestão de Janelas) ---
  "module/polywins" = {
    type = "custom/script";
    exec = "${scripts.polywinsScript}";
    tail = true;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
  };

  # --- Mídia / Playerctl (Interativo com Botões, Scroll e OSD) ---
  "module/media" = {
    type = "custom/script";
    exec = "${scripts.mediaScript}";
    interval = 1;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
    scroll-up = "${scripts.mediaControlScript} next";
    scroll-down = "${scripts.mediaControlScript} prev";
    click-right = "${scripts.mediaControlScript} next";
    click-middle = "${scripts.mediaControlScript} stop";
  };

  # --- Bluetooth (Status Dinâmico na Polybar & Menu Rofi) ---
  "module/bluetooth" = {
    type = "custom/script";
    exec = "${scripts.bluetoothScript}";
    interval = 5;
    format = "%{A1:${scripts.rofiBluetoothMenu}:}%{A2:${pkgs.blueman}/bin/blueman-manager:}%{A3:${scripts.rofiBluetoothMenu} --toggle:}<label>%{A}%{A}%{A}";
    label = "%output%";
    label-padding = 1;
    label-foreground = colors.sapphire;
    click-left = "${scripts.rofiBluetoothMenu}";
    click-middle = "${pkgs.blueman}/bin/blueman-manager";
    click-right = "${scripts.rofiBluetoothMenu} --toggle";
  };

  # --- Uso de CPU ---
  "module/cpu" = {
    type = "internal/cpu";
    interval = 2;
    format = "<label>";
    format-prefix = "󰍛 ";
    format-prefix-foreground = colors.sky;
    label = "%percentage:2%%";
    label-foreground = colors.text;
    label-padding = 1;
  };

  # --- Uso de Memória ---
  "module/memory" = {
    type = "internal/memory";
    interval = 2;
    format = "<label>";
    format-prefix = "󰘚 ";
    format-prefix-foreground = colors.green;
    label = "%percentage_used:2%%";
    label-foreground = colors.text;
    label-padding = 1;
  };

  # --- Temperatura da CPU (Script Dinâmico Universal) ---
  "module/temperature" = {
    type = "custom/script";
    exec = "${scripts.temperatureScript}";
    interval = 3;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
  };

  # --- Armazenamento em Disco (SSD / Raiz) ---
  "module/disk" = {
    type = "internal/fs";
    mount-0 = "/";
    interval = 30;
    fixed-values = true;
    spacing = 0;

    format-mounted = "<label-mounted>";
    format-mounted-prefix = "󰋊";
    format-mounted-prefix-foreground = colors.peach;
    label-mounted = "%free%";
    label-mounted-foreground = colors.text;
    label-mounted-padding = 1;

    format-unmounted = "";
  };

  # --- Tempo de Atividade do Sistema (Uptime) ---
  "module/uptime" = {
    type = "custom/script";
    exec = "${scripts.uptimeScript}";
    interval = 60;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
  };

  # --- Volume & Áudio (Detecção Dinâmica de Saída: Fones, Alto-Falantes, HDMI, Bluetooth) ---
  "module/pulseaudio" = {
    type = "custom/script";
    exec = "${scripts.audioScript}";
    tail = true;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
    click-left = "${scripts.audioControlScript} toggle-mute";
    click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
    click-middle = "${scripts.audioControlScript} next-sink";
    scroll-up = "${scripts.audioControlScript} volume-up";
    scroll-down = "${scripts.audioControlScript} volume-down";
  };

  # --- Brilho da Tela (Script com Controle Dinâmico e Scroll) ---
  "module/backlight" = {
    type = "custom/script";
    exec = "${scripts.backlightScript}";
    interval = 1;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
    scroll-up = "${scripts.backlightScript} up";
    scroll-down = "${scripts.backlightScript} down";
  };

  # --- Bateria ---
  "module/battery" = {
    type = "internal/battery";
    full-at = 98;
    low-at = 15;
    battery = cfg.battery;
    adapter = cfg.adapter;
    poll-interval = 5;

    format-charging = "<animation-charging> <label-charging>";
    format-discharging = "<ramp-capacity> <label-discharging>";
    format-full = "<ramp-capacity> <label-full>";

    label-charging = "%percentage%%";
    label-discharging = "%percentage%%";
    label-full = "100%";
    label-charging-padding = 1;
    label-discharging-padding = 1;
    label-full-padding = 1;

    ramp-capacity-0 = "󰂎";
    ramp-capacity-1 = "󰁺";
    ramp-capacity-2 = "󰁻";
    ramp-capacity-3 = "󰁼";
    ramp-capacity-4 = "󰁽";
    ramp-capacity-5 = "󰁾";
    ramp-capacity-6 = "󰁿";
    ramp-capacity-7 = "󰂀";
    ramp-capacity-8 = "󰂁";
    ramp-capacity-9 = "󰂂";
    ramp-capacity-10 = "󰁹";
    ramp-capacity-foreground = colors.green;

    animation-charging-0 = "󰂆";
    animation-charging-1 = "󰂇";
    animation-charging-2 = "󰂈";
    animation-charging-3 = "󰂉";
    animation-charging-4 = "󰂊";
    animation-charging-5 = "󰂋";
    animation-charging-6 = "󰂅";
    animation-charging-foreground = colors.green;
    animation-charging-framerate = 750;
  };

  # --- Rede (Cabo / Wi-Fi Dinâmico) & Menu Interativo ---
  "module/network" = {
    type = "custom/script";
    exec = "${scripts.networkScript}";
    interval = 2;

    format = "%{A1:${scripts.rofiWifiMenu}:}%{A3:${pkgs.networkmanagerapplet}/bin/nm-connection-editor:}<label>%{A}%{A}";
    label = "%output%";
    label-foreground = colors.text;
    label-padding = 1;

    click-left = "${scripts.rofiWifiMenu}";
    click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  };

  # --- Velocidade de Tráfego de Rede (Download / Upload Universal) ---
  "module/netspeed" = {
    type = "custom/script";
    exec = "${scripts.netspeedScript}";
    interval = 1;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
  };

  # --- Layout do Teclado (Troca Dinâmica ao Clicar / Atalho Alt+Shift / Menu Rofi com Botão Direito) ---
  "module/keyboard" = {
    type = "internal/xkeyboard";
    blacklist-0 = "num lock";
    blacklist-1 = "scroll lock";

    format = "%{A3:${scripts.rofiKeyboardMenu}:}<label-layout> <label-indicator>%{A}";
    format-prefix = "󰌌 ";
    format-prefix-foreground = colors.sapphire;

    label-layout = lib.mkDefault "%layout%";
    label-layout-foreground = colors.text;
    label-layout-padding = 1;

    label-indicator-on-caps = "CAPS";
    label-indicator-on-caps-foreground = colors.base;
    label-indicator-on-caps-background = colors.red;
    label-indicator-on-caps-padding = 1;
  };

  # --- Data & Hora (Elegante e Dinâmico) ---
  "module/date" = {
    type = "internal/date";
    interval = 1;
    date = "%d/%m";
    time = "%H:%M";
    date-alt = "%A, %d/%m";
    time-alt = "%H:%M:%S";

    format = "<label>";
    format-prefix = "󰃭 ";
    format-prefix-foreground = colors.blue;
    label = "%{F${colors.text}}%date%%{F-}  %{F${colors.sapphire}}󰥔%{F-} %{F${colors.text}}%time%%{F-}";
    label-padding = 1;
  };

  # --- Botão Power Menu ---
  "module/powermenu" = {
    type = "custom/text";
    format = "%{A1:${scripts.rofiPowerMenu}:}<label>%{A}";
    label = "󰐥";
    label-font = 4;
    label-foreground = colors.red;
    label-padding = 1;
    click-left = "${scripts.rofiPowerMenu}";
  };

  # --- Filtro Noturno / Redshift (Luz Noturna & Temperatura de Cor) ---
  "module/redshift" = {
    type = "custom/script";
    exec = "${scripts.redshiftScript} status";
    interval = 3;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
    click-left = "${scripts.redshiftScript} toggle";
    click-right = "${scripts.redshiftScript} reset";
    scroll-up = "${scripts.redshiftScript} increase";
    scroll-down = "${scripts.redshiftScript} decrease";
  };

  # --- Indicador Dinâmico de Layout do BSPWM (bsp-layout) ---
  "module/bsp-layout" = {
    type = "custom/script";
    exec = "${scripts.bspLayoutScript}";
    interval = 1;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
    click-left = "${scripts.rofiLayoutMenu}";
    click-right = "${scripts.bspLayoutSwitchScript} next";
    click-middle = "${scripts.bspLayoutSwitchScript} reset";
    scroll-up = "${scripts.bspLayoutSwitchScript} next";
    scroll-down = "${scripts.bspLayoutSwitchScript} prev";
  };

  # --- Notificações (Dunst / Central Interativa Rofi) ---
  "module/notifications" = {
    type = "custom/script";
    exec = "${scripts.notificationStatusScript}";
    interval = 2;
    format = "<label>";
    label = "%output%";
    label-padding = 1;
    click-left = "${scripts.rofiNotificationMenu}";
    click-right = "${scripts.notificationToggleDndScript}";
    click-middle = "${pkgs.dunst}/bin/dunstctl history-clear";
  };

  "settings" = {
    screenchange-reload = true;
    pseudo-transparency = false;
  };
}
// mkColoredEncapModules
// lib.optionalAttrs (cfg.tray.enable or false) {
  # --- Bandeja do Sistema (Stalonetray Toggle Button) ---
  "module/tray" = {
    type = "custom/text";
    format = "<label>";
    label = "󱊖";
    label-font = 4;
    label-foreground = colors.blue-alt;
    label-padding = 1;
    click-left = "${scripts.stalonetrayToggleScript}";
  };
}
