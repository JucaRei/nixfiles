{
  pkgs,
  colors,
  scripts,
  ...
}:
{
  # --- Espaçadores e Separadores ---
  "module/sep" = {
    type = "custom/text";
    format = "<label>";
    label = "  ";
    label-foreground = colors.transparent;
  };

  # --- Lançador de Aplicativos (NixOS Logo) ---
  "module/launcher" = {
    type = "custom/text";
    format = "<label>";
    label = " 󱄅 ";
    label-font = 4;
    label-foreground = colors.mauve;
    label-background = colors.surface0;
    label-padding = 1;
    click-left = "${pkgs.rofi}/bin/rofi -show drun";
  };

  # --- Workspaces Nativos do BSPWM ---
  "module/bspwm" = {
    type = "internal/bspwm";
    pin-workspaces = false;
    enable-click = true;
    enable-scroll = true;
    reverse-scroll = false;
    inline-mode = false;

    format = "<label-state> <label-mode>";
    format-background = colors.surface0;
    format-padding = 1;

    label-focused = "󰮯 %name%";
    label-focused-foreground = colors.crust;
    label-focused-background = colors.mauve;
    label-focused-padding = 2;

    label-occupied = "󰊠 %name%";
    label-occupied-foreground = colors.text;
    label-occupied-background = colors.surface1;
    label-occupied-padding = 2;

    label-urgent = "󰀦 %name%";
    label-urgent-foreground = colors.crust;
    label-urgent-background = colors.red;
    label-urgent-padding = 2;

    label-empty = "%name%";
    label-empty-foreground = colors.surface2;
    label-empty-padding = 2;

    label-monocle = " 󰍉 ";
    label-monocle-foreground = colors.yellow;
    label-floating = " 󰖲 ";
    label-floating-foreground = colors.peach;
    label-fullscreen = " 󰊓 ";
    label-fullscreen-foreground = colors.mauve;
  };

  # --- Título da Janela Ativa ---
  "module/xwindow" = {
    type = "internal/xwindow";
    format = "<label>";
    format-prefix = "󰣆 ";
    format-prefix-foreground = colors.blue;
    format-background = colors.surface0;
    format-padding = 2;
    label = "%title:0:32:...%";
    label-foreground = colors.subtext0;
  };

  # --- Relógio e Data Nativos ---
  "module/date" = {
    type = "internal/date";
    interval = 1;

    date = "󰥔 %H:%M";
    date-alt = "󰃭 %A, %d/%m/%Y  󰥔 %H:%M:%S";

    format = "<label>";
    format-background = colors.surface0;
    format-foreground = colors.mauve;
    format-padding = 2;

    label = "%date%";
  };

  # --- Monitor de CPU Nativo ---
  "module/cpu" = {
    type = "internal/cpu";
    interval = 2;
    format = "<label>";
    format-prefix = " ";
    format-prefix-foreground = colors.peach;
    format-background = colors.surface0;
    format-padding = 1;
    label = "%percentage%%";
    label-foreground = colors.text;
  };

  # --- Monitor de Memória RAM Nativo ---
  "module/memory" = {
    type = "internal/memory";
    interval = 2;
    format = "<label>";
    format-prefix = "󰍛 ";
    format-prefix-foreground = colors.green;
    format-background = colors.surface0;
    format-padding = 1;
    label = "%percentage_used%%";
    label-foreground = colors.text;
  };

  # --- Controle de Volume Nativo (Pulseaudio / Pipewire) ---
  "module/pulseaudio" = {
    type = "internal/pulseaudio";
    use-ui-max = true;
    interval = 5;

    format-volume = "<ramp-volume> <label-volume>";
    format-volume-background = colors.surface0;
    format-volume-padding = 1;
    label-volume = "%percentage%%";
    label-volume-foreground = colors.text;

    ramp-volume-0 = "󰕿";
    ramp-volume-1 = "󰖀";
    ramp-volume-2 = "󰕾";
    ramp-volume-foreground = colors.sapphire;

    format-muted = "<label-muted>";
    format-muted-background = colors.surface0;
    format-muted-padding = 1;
    label-muted = "󰝟 Mudo";
    label-muted-foreground = colors.red;

    click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
  };

  # --- Brilho da Tela (Backlight) ---
  "module/backlight" = {
    type = "custom/script";
    exec = "${pkgs.brightnessctl}/bin/brightnessctl -m | ${pkgs.gawk}/bin/awk -F, '{print $4}'";
    interval = 3;
    scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
    scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
    format = "<label>";
    format-prefix = "󰃟 ";
    format-prefix-foreground = colors.yellow;
    format-background = colors.surface0;
    format-padding = 1;
    label = "%output%";
    label-foreground = colors.text;
  };

  # --- Bateria Nativa ---
  "module/battery" = {
    type = "internal/battery";
    full-at = 99;
    low-at = 15;
    battery = "BAT0";
    adapter = "ADP1";
    poll-interval = 5;

    format-charging = "<animation-charging> <label-charging>";
    format-charging-background = colors.surface0;
    format-charging-padding = 1;
    label-charging = "%percentage%%";
    label-charging-foreground = colors.green;

    format-discharging = "<ramp-capacity> <label-discharging>";
    format-discharging-background = colors.surface0;
    format-discharging-padding = 1;
    label-discharging = "%percentage%%";
    label-discharging-foreground = colors.text;

    format-full = "<ramp-capacity> <label-full>";
    format-full-background = colors.surface0;
    format-full-padding = 1;
    label-full = "%percentage%%";
    label-full-foreground = colors.green;

    format-low = "<ramp-capacity> <label-low>";
    format-low-background = colors.surface0;
    format-low-padding = 1;
    label-low = "%percentage%% (Fraca)";
    label-low-foreground = colors.red;

    ramp-capacity-0 = "󰁺";
    ramp-capacity-1 = "󰁼";
    ramp-capacity-2 = "󰁾";
    ramp-capacity-3 = "󰂀";
    ramp-capacity-4 = "󰁹";
    ramp-capacity-foreground = colors.teal;

    animation-charging-0 = "󰢜";
    animation-charging-1 = "󰂇";
    animation-charging-2 = "󰢝";
    animation-charging-3 = "󰂉";
    animation-charging-4 = "󰂅";
    animation-charging-foreground = colors.green;
    animation-charging-framerate = 750;
  };

  # --- Indicador de Rede Dinâmico e Leve ---
  "module/network" = {
    type = "custom/script";
    exec = "${scripts.networkScript}";
    interval = 4;
    format = "<label>";
    format-background = colors.surface0;
    format-padding = 1;
    click-left = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  };

  # --- Menu de Energia ---
  "module/powermenu" = {
    type = "custom/text";
    format = "<label>";
    label = " 󰐥 ";
    label-font = 4;
    label-foreground = colors.red;
    label-background = colors.surface0;
    label-padding = 1;
    click-left = "${scripts.powerMenuScript}";
  };
}
