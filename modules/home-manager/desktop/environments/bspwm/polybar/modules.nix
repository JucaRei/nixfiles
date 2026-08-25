{
  pkgs,
  scripts,
  ...
}:
{
  # --- Cápsulas Decorativas / Pills (gh0stzk style) ---
  "module/bi" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T4}%{T-}";
    label-foreground = "\${colors.surface0}";
    label-background = "\${colors.transparent}";
  };

  "module/bd" = {
    type = "custom/text";
    format = "<label>";
    label = "%{T4}%{T-}";
    label-foreground = "\${colors.surface0}";
    label-background = "\${colors.transparent}";
  };

  "module/sep" = {
    type = "custom/text";
    format = "<label>";
    label = " ";
    label-foreground = "\${colors.transparent}";
    label-background = "\${colors.transparent}";
  };

  "module/dots" = {
    type = "custom/text";
    format = "<label>";
    label = "  ";
    label-foreground = "\${colors.surface2}";
    label-background = "\${colors.surface0}";
  };

  # --- Lançador de Aplicativos (NixOS Logo Pill) ---
  "module/launcher" = {
    type = "custom/text";
    format = "%{A1:${pkgs.rofi}/bin/rofi -show drun:}<label>%{A}";
    label = "󱄅";
    label-font = 4;
    label-foreground = "\${colors.blue}";
    label-background = "\${colors.surface0}";
    label-padding = 1;
    click-left = "${pkgs.rofi}/bin/rofi -show drun";
  };

  # --- Workspaces do BSPWM (Pills Dinâmicos) ---
  "module/bspwm" = {
    type = "internal/bspwm";
    pin-workspaces = true;
    enable-click = true;
    enable-scroll = true;
    reverse-scroll = false;
    inline-mode = false;

    format = "<label-state> <label-mode>";
    format-background = "\${colors.surface0}";

    label-focused = "󰮯 %name%";
    label-focused-foreground = "\${colors.base}";
    label-focused-background = "\${colors.blue}";
    label-focused-padding = 2;
    label-focused-margin = 0;

    label-occupied = "󰊠 %name%";
    label-occupied-foreground = "\${colors.text}";
    label-occupied-background = "\${colors.surface0}";
    label-occupied-padding = 2;
    label-occupied-margin = 0;

    label-urgent = "󰀦 %name%";
    label-urgent-foreground = "\${colors.base}";
    label-urgent-background = "\${colors.red}";
    label-urgent-padding = 2;
    label-urgent-margin = 0;

    label-empty = "%name%";
    label-empty-foreground = "\${colors.surface2}";
    label-empty-background = "\${colors.surface0}";
    label-empty-padding = 2;
    label-empty-margin = 0;

    label-monocle = " 󰍉 ";
    label-monocle-foreground = "\${colors.yellow}";
    label-floating = " 󰖲 ";
    label-floating-foreground = "\${colors.peach}";
    label-fullscreen = " 󰊓 ";
    label-fullscreen-foreground = "\${colors.mauve}";
  };

  # --- Título da Janela Ativa ---
  "module/xwindow" = {
    type = "internal/xwindow";
    format-prefix = "󰣆 ";
    format-prefix-foreground = "\${colors.sapphire}";
    format-background = "\${colors.surface0}";
    label = "%title:0:28:...%";
    label-foreground = "\${colors.subtext0}";
    label-padding = 1;
  };

  # --- Mídia / Playerctl ---
  "module/media" = {
    type = "custom/script";
    exec = "${scripts.mediaScript}";
    interval = 2;
    format = "<label>";
    format-background = "\${colors.surface0}";
    format-foreground = "\${colors.lavender}";
    label = "%output%";
    label-padding = 1;
    click-left = "${pkgs.playerctl}/bin/playerctl play-pause";
    click-right = "${pkgs.playerctl}/bin/playerctl next";
  };

  # --- Bluetooth ---
  "module/bluetooth" = {
    type = "custom/script";
    exec = "${scripts.bluetoothScript}";
    interval = 2;
    format = "%{A1:${scripts.rofiBluetoothMenu}:}%{A3:${scripts.rofiBluetoothMenu}:}<label>%{A}%{A}";
    format-background = "\${colors.surface0}";
    label = "%output%";
    label-padding = 1;
    label-foreground = "\${colors.sapphire}";
    click-left = "${scripts.rofiBluetoothMenu}";
  };

  # --- Uso de CPU ---
  "module/cpu" = {
    type = "internal/cpu";
    interval = 2;
    format = "<label>";
    format-prefix = "󰍛 ";
    format-prefix-foreground = "\${colors.teal}";
    format-background = "\${colors.surface0}";
    label = "%percentage:2%%";
    label-foreground = "\${colors.text}";
    label-padding = 1;
  };

  # --- Uso de Memória ---
  "module/memory" = {
    type = "internal/memory";
    interval = 2;
    format = "<label>";
    format-prefix = "󰘚 ";
    format-prefix-foreground = "\${colors.mauve}";
    format-background = "\${colors.surface0}";
    label = "%percentage_used:2%%";
    label-foreground = "\${colors.text}";
    label-padding = 1;
  };

  # --- Volume & Áudio ---
  "module/pulseaudio" = {
    type = "internal/pulseaudio";
    use-ui-max = true;
    interval = 2;

    format-volume = "<ramp-volume> <label-volume>";
    format-volume-background = "\${colors.surface0}";
    label-volume = "%percentage%%";
    label-volume-foreground = "\${colors.text}";
    label-volume-padding = 1;

    ramp-volume-0 = "󰕿";
    ramp-volume-1 = "󰖀";
    ramp-volume-2 = "󰕾";
    ramp-volume-foreground = "\${colors.blue}";

    format-muted = "<label-muted>";
    format-muted-prefix = "󰝟 ";
    format-muted-prefix-foreground = "\${colors.red}";
    format-muted-background = "\${colors.surface0}";
    label-muted = "0%";
    label-muted-foreground = "\${colors.subtext0}";
    label-muted-padding = 1;

    click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
  };

  # --- Brilho da Tela ---
  "module/backlight" = {
    type = "internal/backlight";
    card = "nv_backlight";
    use-actual-brightness = true;
    enable-scroll = true;

    format = "<ramp> <label>";
    format-background = "\${colors.surface0}";
    label = "%percentage%%";
    label-foreground = "\${colors.text}";
    label-padding = 1;

    ramp-0 = "󰃞";
    ramp-1 = "󰃝";
    ramp-2 = "󰃟";
    ramp-3 = "󰃠";
    ramp-foreground = "\${colors.yellow}";
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
    format-charging-background = "\${colors.surface0}";
    format-discharging = "<ramp-capacity> <label-discharging>";
    format-discharging-background = "\${colors.surface0}";
    format-full = "<ramp-capacity> <label-full>";
    format-full-background = "\${colors.surface0}";

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
    ramp-capacity-foreground = "\${colors.green}";

    animation-charging-0 = "󰂆";
    animation-charging-1 = "󰂇";
    animation-charging-2 = "󰂈";
    animation-charging-3 = "󰂉";
    animation-charging-4 = "󰂊";
    animation-charging-5 = "󰂋";
    animation-charging-6 = "󰂅";
    animation-charging-foreground = "\${colors.green}";
    animation-charging-framerate = 750;
  };

  # --- Rede Wi-Fi & Menu Interativo ---
  "module/network" = {
    type = "internal/network";
    interface-type = "wireless";
    interval = 2;

    format-connected = "%{A1:${scripts.rofiWifiMenu}:}%{A3:${pkgs.networkmanagerapplet}/bin/nm-connection-editor:}<ramp-signal> <label-connected>%{A}%{A}";
    format-connected-background = "\${colors.surface0}";
    label-connected = "%essid%";
    label-connected-foreground = "\${colors.text}";
    label-connected-padding = 1;

    ramp-signal-0 = "󰤯";
    ramp-signal-1 = "󰤟";
    ramp-signal-2 = "󰤢";
    ramp-signal-3 = "󰤥";
    ramp-signal-4 = "󰤨";
    ramp-signal-foreground = "\${colors.teal}";

    format-disconnected = "%{A1:${scripts.rofiWifiMenu}:}%{A3:${pkgs.networkmanagerapplet}/bin/nm-connection-editor:}<label-disconnected>%{A}%{A}";
    format-disconnected-prefix = "󰤮 ";
    format-disconnected-prefix-foreground = "\${colors.red}";
    format-disconnected-background = "\${colors.surface0}";
    label-disconnected = "Offline";
    label-disconnected-foreground = "\${colors.subtext0}";
    label-disconnected-padding = 1;

    click-left = "${scripts.rofiWifiMenu}";
    click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  };

  # --- Velocidade de Tráfego de Rede (Download / Upload) ---
  "module/netspeed" = {
    type = "internal/network";
    interface-type = "wireless";
    interval = 1;

    format-connected = "<label-connected>";
    format-connected-background = "\${colors.surface0}";
    label-connected = "%{F#89b4fa}󰇚 %downspeed:7%%{F-}  %{F#fab387}󰕒 %upspeed:7%%{F-}";
    label-connected-foreground = "\${colors.text}";
    label-connected-padding = 1;

    format-disconnected = "<label-disconnected>";
    format-disconnected-background = "\${colors.surface0}";
    label-disconnected = "%{F#89b4fa}󰇚 0KB/s%{F-}  %{F#fab387}󰕒 0KB/s%{F-}";
    label-disconnected-foreground = "\${colors.surface2}";
    label-disconnected-padding = 1;
  };

  # --- Data & Hora ---
  "module/date" = {
    type = "internal/date";
    interval = 1;
    date = "%d/%m";
    time = "%H:%M";
    date-alt = "%A, %d de %B de %Y";
    time-alt = "%H:%M:%S";

    format = "<label>";
    format-prefix = "󰥔 ";
    format-prefix-foreground = "\${colors.sapphire}";
    format-background = "\${colors.surface0}";
    label = "%date% %time%";
    label-foreground = "\${colors.text}";
    label-padding = 1;
  };

  # --- Botão Power Menu ---
  "module/powermenu" = {
    type = "custom/text";
    format = "%{A1:${scripts.rofiPowerMenu}:}<label>%{A}";
    label = " 󰐥 ";
    label-font = 4;
    label-foreground = "\${colors.red}";
    label-background = "\${colors.surface0}";
    label-padding = 1;
    click-left = "${scripts.rofiPowerMenu}";
  };

  "settings" = {
    screenchange-reload = true;
    pseudo-transparency = true;
  };
}
