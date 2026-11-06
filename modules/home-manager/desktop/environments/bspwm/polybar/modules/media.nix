{
  pkgs,
  colors,
  scripts,
  ...
}:
{
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

  # --- Bluetooth (Status Dinâmico na Polybar & Menu Rofi) ---
  "module/bluetooth" = {
    type = "custom/script";
    exec = "${scripts.bluetoothScript}";
    interval = 3;
    format = "%{A1:${scripts.rofiBluetoothMenu}:}%{A2:${pkgs.blueman}/bin/blueman-manager:}%{A3:${scripts.rofiBluetoothMenu} --toggle:}%{A4:${scripts.rofiBluetoothMenu} --scan:}%{A5:${scripts.rofiBluetoothMenu} --scan:}<label>%{A}%{A}%{A}%{A}%{A}";
    label = "%output%";
    label-padding = 1;
    label-foreground = colors.sapphire;
    click-left = "${scripts.rofiBluetoothMenu}";
    click-middle = "${pkgs.blueman}/bin/blueman-manager";
    click-right = "${scripts.rofiBluetoothMenu} --toggle";
    scroll-up = "${scripts.rofiBluetoothMenu} --scan";
    scroll-down = "${scripts.rofiBluetoothMenu} --scan";
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
}
