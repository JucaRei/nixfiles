{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.dwm;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Utilitários do DWM
      dmenu
      slstatus
      xdotool
      wmctrl
      xorg.xsetroot
      xorg.xrandr
      xorg.xrdb
      xorg.xinput
      picom
      rofi-power-menu
      brightnessctl
      networkmanagerapplet
      libnotify

      # Wallpaper e Visualização de Imagens
      feh
      sxiv

      # Dependências de captura de tela utilizadas pelos scripts do dwm-titus
      maim
      slop
      xclip

      # Dependências de sistema / ferramentas usadas pelos scripts do Titus
      gawk
      gnused
      coreutils
      bc
      jq
    ];

    # Associações padrão de mimetypes para imagens usando sxiv
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/png" = [ "sxiv.desktop" ];
        "image/jpeg" = [ "sxiv.desktop" ];
        "image/jpg" = [ "sxiv.desktop" ];
        "image/gif" = [ "sxiv.desktop" ];
        "image/webp" = [ "sxiv.desktop" ];
        "image/bmp" = [ "sxiv.desktop" ];
      };
    };
  };
}
