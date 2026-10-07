{
  lib,
  pkgs,
  colors,
  scripts,
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

  # --- Lançador de Aplicativos (Logo do Sistema Operacional Dinâmico) ---
  "module/launcher" = {
    type = "custom/script";
    exec = "${scripts.osLogoScript}";
    format = "%{A1:${pkgs.rofi}/bin/rofi -show drun:}<label>%{A}";
    label = "%output%";
    label-font = 4;
    label-foreground = colors.blue;
    label-padding = 1;
    click-left = "${pkgs.rofi}/bin/rofi -show drun";
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
    interval = 10;
    format = "%{A1:${scripts.rofiBluetoothMenu}:}%{A3:${scripts.rofiBluetoothMenu} --toggle:}<label>%{A}%{A}";
    label = "%output%";
    label-padding = 1;
    label-foreground = colors.sapphire;
    click-left = "${scripts.rofiBluetoothMenu}";
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

  # --- Volume & Áudio ---
  "module/pulseaudio" = {
    type = "internal/pulseaudio";
    use-ui-max = true;
    interval = 2;

    format-volume = "<ramp-volume> <label-volume>";
    label-volume = "%percentage%%";
    label-volume-foreground = colors.text;
    label-volume-padding = 1;

    ramp-volume-0 = "󰕿";
    ramp-volume-1 = "󰖀";
    ramp-volume-2 = "󰕾";
    ramp-volume-foreground = colors.blue;

    format-muted = "<label-muted>";
    format-muted-prefix = "󰝟 ";
    format-muted-prefix-foreground = colors.red;
    label-muted = "0%";
    label-muted-foreground = colors.subtext0;
    label-muted-padding = 1;

    click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
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
    battery = "BAT0";
    adapter = "ADP1";
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
    format-background = colors.base;
    tray-spacing = "8px";
    tray-size = "16px";
    tray-background = colors.base;
  };

  "settings" = {
    screenchange-reload = true;
    pseudo-transparency = false;
  };
}
