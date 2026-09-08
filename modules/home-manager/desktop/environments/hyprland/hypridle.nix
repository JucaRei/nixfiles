{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.hyprland.hypridle;
in
{
  options.desktop.hyprland.hypridle = {
    enable = mkOption {
      type = bool;
      default = config.desktop.hyprland.enable;
      description = "Enable hypridle daemon for hyprland";
    };
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      package = pkgs.hypridle;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        };

        listener = [
          # 2.5 min: Diminui o brilho do monitor e desliga iluminação do teclado
          {
            timeout = 150;
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
          }
          {
            timeout = 150;
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd '*::kbd_backlight' set 0 || true";
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd '*::kbd_backlight' || true";
          }
          # 5 min: Bloqueia a tela
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          # 10 min: Desliga os monitores
          {
            timeout = 600;
            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
          # 30 min: Suspende o sistema
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
