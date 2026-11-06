{
  pkgs,
  colors,
  scripts,
  ...
}:
{
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
}
