{
  lib,
  pkgs,
  colors,
  scripts,
  cfg ? {
    battery = "BAT0";
    adapter = "ADP1";
  },
  ...
}:
{
  # --- Divisores & Espaçadores Elegantes (Estilo Waybar / Catppuccin) ---
  "module/sep" = {
    type = "custom/text";
    format = "<label>";
    label = "  %{F#45475a}│%{F-}  ";
  };

  "module/dots" = {
    type = "custom/text";
    format = "<label>";
    label = "  %{F#45475a}·%{F-}  ";
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

  # --- Cápsulas Decorativas Legadas (gh0stzk style com  e  mantidas para compatibilidade) ---
  "module/bi" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = colors.surface0;
    label-background = colors.transparent;
  };

  "module/bd" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T5}%{T-}";
    label-foreground = colors.surface0;
    label-background = colors.transparent;
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
    ws-icon-9 = "0;〇";
    ws-icon-10 = "10;〇";
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
    spacing = 1;

    format-mounted = "<label-mounted>";
    format-mounted-prefix = "󰋊 ";
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
    interval = 2;
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
    click-left = "${scripts.bspLayoutSwitchScript} next";
    click-right = "${scripts.rofiLayoutMenu}";
    click-middle = "${scripts.bspLayoutSwitchScript} reset";
    scroll-up = "${scripts.bspLayoutSwitchScript} next";
    scroll-down = "${scripts.bspLayoutSwitchScript} prev";
  };

  # --- Bandeja do Sistema (System Tray - Polybar 3.7+) ---
  "module/tray" = {
    type = "internal/tray";
    format = "<tray>";
    tray-spacing = "8px";
    tray-size = "16px";
  };

  # =========================================================================
  # MÓDULOS ESTILO ZPROGER (https://github.com/Zproger/bspwm-dotfiles)
  # Cápsulas arredondadas (#2b2f37), workspaces numerados e coloridos,
  # estatísticas com ícones temáticos, relógio em cápsula e botões diretos
  # =========================================================================

  "module/z-round-left" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T4}%{T-}";
    label-foreground = "#2b2f37";
  };

  "module/z-round-right" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T4}%{T-}";
    label-foreground = "#2b2f37";
  };

  "module/z-space" = {
    type = "custom/text";
    format = "<label>";
    label = " ";
  };

  "module/z-launcher" = {
    type = "custom/script";
    exec = "${scripts.osLogoScript}";
    interval = 3600;
    format = "%{A1:${pkgs.rofi}/bin/rofi -show drun:}<label>%{A}";
    label = "%output% ";
    label-font = 4;
    label-padding = 1;
    label-foreground = "#61afef";
    click-left = "${pkgs.rofi}/bin/rofi -show drun";
  };

  "module/z-bspwm" = {
    type = "internal/bspwm";
    pin-workspaces = true;
    inline-mode = false;
    enable-click = true;
    enable-scroll = true;
    reverse-scroll = false;
    fuzzy-match = true;

    format = "<label-state>";
    ws-icon-0 = "1;%{F#F9DE8F}1%{F-}";
    ws-icon-1 = "2;%{F#ff9b93}2%{F-}";
    ws-icon-2 = "3;%{F#95e1d3}3%{F-}";
    ws-icon-3 = "4;%{F#81A1C1}4%{F-}";
    ws-icon-4 = "5;%{F#A3BE8C}5%{F-}";
    ws-icon-5 = "6;%{F#F9DE8F}6%{F-}";
    ws-icon-6 = "7;%{F#ff9b93}7%{F-}";
    ws-icon-7 = "8;%{F#95e1d3}8%{F-}";
    ws-icon-8 = "9;%{F#81A1C1}9%{F-}";
    ws-icon-9 = "0;%{F#F9DE8F}0%{F-}";
    ws-icon-10 = "10;%{F#F9DE8F}0%{F-}";
    ws-icon-default = "%name%";

    label-separator = "";
    label-separator-background = "#2b2f37";

    label-focused = "%icon%";
    label-focused-foreground = "#abb2bf";
    label-focused-underline = "#565c64";
    label-focused-padding = 1;
    label-focused-background = "#2b2f37";

    label-occupied = "%icon%";
    label-occupied-foreground = "#646870";
    label-occupied-background = "#2b2f37";
    label-occupied-padding = 1;

    label-empty = "%icon%";
    label-empty-foreground = "#5c6370";
    label-empty-background = "#2b2f37";
    label-empty-padding = 1;

    label-urgent = "%icon%";
    label-urgent-foreground = "#88C0D0";
    label-urgent-background = "#2b2f37";
    label-urgent-padding = 1;
  };

  "module/z-temperature" = {
    type = "internal/temperature";
    thermal-zone = 0;
    warn-temperature = 70;
    format = "<ramp> <label>";
    format-warn = "<ramp> <label-warn>";
    format-padding = 0;
    label = "%temperature-c%";
    label-warn = "%temperature-c%";
    ramp-0 = "";
    ramp-foreground = "#a4ebf3";
  };

  "module/z-memory" = {
    type = "internal/memory";
    interval = 2;
    format = "<label>";
    format-prefix = " ";
    format-padding = 1;
    format-foreground = "#d19a66";
    label = "%gb_used%";
  };

  "module/z-cpu" = {
    type = "internal/cpu";
    interval = 2;
    format-prefix = " ";
    format = "<label>";
    label = "%percentage%%";
    format-foreground = "#989cff";
  };

  "module/z-time" = {
    type = "internal/date";
    interval = 30;
    format = "<label>";
    format-background = "#2b2f37";
    date = "%{F#888e96}  %H:%M %p%{F-}";
    date-alt = "%{F#61afef}󰃭  %a, %d %b %Y%{F-}";
    label = "%date%";
    label-padding = 1;
  };

  "module/z-battery" = {
    type = "internal/battery";
    full-at = 98;
    low-at = 10;
    battery = cfg.battery;
    adapter = cfg.adapter;
    poll-interval = 5;
    time-format = "%H:%M";

    format-charging = "<animation-charging> <label-charging>";
    format-discharging = "<ramp-capacity> <label-discharging>";
    format-full = "<ramp-capacity> <label-full>";
    format-low = "<label-low> <animation-low>";

    label-charging = "%percentage%% ";
    label-discharging = "%percentage%% ";
    label-full = " 100% ";
    label-low = "%percentage%% ";

    ramp-capacity-0 = "󰂎 ";
    ramp-capacity-1 = "󰁺 ";
    ramp-capacity-2 = "󰁼 ";
    ramp-capacity-3 = "󰁾 ";
    ramp-capacity-4 = "󰂀 ";
    ramp-capacity-foreground = "#A0E8A2";

    animation-charging-0 = "󰂎 ";
    animation-charging-1 = "󰁺 ";
    animation-charging-2 = "󰁼 ";
    animation-charging-3 = "󰁾 ";
    animation-charging-4 = "󰂀 ";
    animation-charging-framerate = 910;
    animation-charging-foreground = "#DF8890";

    animation-low-0 = "󰂎  ";
    animation-low-1 = "󰁺  ";
    animation-low-framerate = 1500;
    animation-low-foreground = "#D35F5D";

    format-discharging-foreground = "#abb2bf";
    format-charging-foreground = "#DF8890";
    format-full-prefix-foreground = "#A0E8A2";
  };

  "module/z-backlight" = {
    type = "internal/backlight";
    card = "\${env:BACKLIGHT_CARD:intel_backlight}";
    use-actual-brightness = true;
    enable-scroll = true;
    scroll-interval = 5;
    format = "<label>";
    format-prefix = "  ";
    format-prefix-foreground = "#61afef";
    format-padding = 1;
  };

  "module/z-wlan" = {
    type = "internal/network";
    interface = "\${env:WLAN_IFACE:wlan0}";
    interval = 3;
    format-connected = "<label-connected>";
    label-connected = "%{A1:${scripts.rofiWifiMenu}:}󰤨 %{A}";
    label-connected-foreground = "#A3BE8C";
    format-disconnected = "<label-disconnected>";
    label-disconnected = "%{A1:${scripts.rofiWifiMenu}:}󰤭 %{A}";
    label-disconnected-foreground = "#D35F5E";
  };

  "module/z-powermenu" = {
    type = "custom/text";
    format = "%{A1:${scripts.rofiPowerMenu}:}<label>%{A}";
    label = " ";
    label-padding = 1;
    click-left = "${scripts.rofiPowerMenu}";
    label-foreground = "#d35f5e";
  };

  "module/z-xkeyboard" = {
    type = "internal/xkeyboard";
    blacklist-0 = "num lock";
    blacklist-1 = "scroll lock";
    format = "%{A3:${scripts.rofiKeyboardMenu}:}<label-layout> <label-indicator>%{A}";
    label-layout = "%layout%";
    label-layout-padding = 1;
    label-layout-foreground = "#abb2bf";
    label-indicator-on = "%name%";
    label-indicator-on-caps = "!";
    label-indicator-on-caps-foreground = "#d35f5e";
  };

  "module/z-alsa" = {
    type = "internal/alsa";
    format-volume = "<ramp-volume> <label-volume>";
    format-volume-padding = 1;
    format-muted = "󰝟";
    format-muted-padding = 1;
    label-volume = "%percentage%%";
    ramp-volume-0 = "%{F#d35f5e}󰕿 %{F-}";
    ramp-volume-1 = "%{F#d35f5e}󰕿 %{F-}";
    ramp-volume-2 = "%{F#d35f5e}󰕿 %{F-}";
    ramp-volume-3 = "%{F#d35f5e}󰕿 %{F-}";
    ramp-volume-4 = "%{F#d35f5e}󰕿 %{F-}";
    ramp-volume-5 = "%{F#d35f5e}󰕾 %{F-}";
    ramp-volume-6 = "%{F#d35f5e}󰕾 %{F-}";
    ramp-volume-7 = "%{F#d35f5e}󰕾 %{F-}";
    ramp-volume-8 = "%{F#d35f5e}󰕾 %{F-}";
    ramp-volume-9 = "%{F#d35f5e}󰕾 %{F-}";
    ramp-headphones-0 = "󰋋";
    ramp-headphones-1 = "󰋋";
    format-volume-foreground = "#abb2bf";
    format-muted-foreground = "#d35f5e";
  };

  "settings" = {
    screenchange-reload = true;
    pseudo-transparency = false;
  };
}
