{
  lib,
  colors,
  scripts,
  cfg ? {
    battery = "BAT0";
    adapter = "ADP1";
    tray = {
      enable = false;
    };
  },
  ...
}:
{
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

  # --- Bateria ---
  "module/battery" = {
    type = "internal/battery";
    full-at = 98;
    low-at = 15;
    inherit (cfg) battery;
    inherit (cfg) adapter;
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

  "settings" = {
    screenchange-reload = true;
    pseudo-transparency = false;
  };
}
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
    click-right = "${scripts.stalonetrayToggleScript} restart";
  };
}
