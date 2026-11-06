# modules/home-manager/desktop/environments/bspwm/rules.nix
# Regras declarativas de janelas do BSPWM (floating, center, follow, geometry).
{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop.bspwm;
in
{
  config = lib.mkIf cfg.enable {
    xsession.windowManager.bspwm.rules = {
      # --- Utilitários de Sistema, Áudio e Vídeo ---
      "Lxappearance" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "lxappearance" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Galculator" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "galculator" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Gnome-calculator" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Qalculate-gtk" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Pavucontrol" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "pavucontrol" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Arandr" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "arandr" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Nitrogen" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "nitrogen" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Nm-connection-editor" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "nm-connection-editor" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Blueman-manager" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Blueman-adapters" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Blueman-assistant" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Blueman-services" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Blueman-sendto" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Stalonetray" = {
        state = "floating";
        sticky = true;
        border = false;
        manage = false;
      };
      "stalonetray" = {
        state = "floating";
        sticky = true;
        border = false;
        manage = false;
      };
      "GParted" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "gparted" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Xfce4-taskmanager" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "File-roller" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Engrampa" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Catfish" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "feh" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Viewnior" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Kvantum Manager" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Font-manager" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "xdg-desktop-portal-gtk" = {
        state = "floating";
        center = true;
        follow = true;
        rectangle = "850x550+0+0";
      };
      "Xdg-desktop-portal-gtk" = {
        state = "floating";
        center = true;
        follow = true;
        rectangle = "850x550+0+0";
      };
      "scrcpy" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "Scrcpy" = {
        state = "floating";
        center = true;
        follow = true;
      };
      ".scrcpywrap" = {
        state = "floating";
        center = true;
        follow = true;
      };
      ".scrcpy-wrapped" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "scrcpy-wrapped" = {
        state = "floating";
        center = true;
        follow = true;
      };
      "bspwm-scratch" = {
        state = "floating";
        sticky = true;
      };
    };
  };
}

