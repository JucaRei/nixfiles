{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.wayland;
  isTraditional = config.desktop.display-servers.backend == "wayland" && cfg.shell == "traditional";
in
{
  options.desktop.wayland.traditional.hypridle = {
    enable = lib.my.mkBool isTraditional "Habilitar hypridle daemon para o shell tradicional Wayland";
  };

  # Retrocompatibilidade
  options.desktop.hyprland.hypridle = {
    enable = lib.my.mkBool config.desktop.wayland.traditional.hypridle.enable "Opção de retrocompatibilidade para hypridle";
  };

  config = mkIf (isTraditional && config.desktop.wayland.traditional.hypridle.enable) {
    services.hypridle = {
      enable = true;
      package = pkgs.hypridle;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd =
            if (cfg.compositor == "hyprland" || config.desktop.hyprland.enable) then
              "${pkgs.hyprland}/bin/hyprctl dispatch dpms on"
            else
              "true";
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
            on-timeout =
              if (cfg.compositor == "hyprland" || config.desktop.hyprland.enable) then
                "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"
              else
                "true";
            on-resume =
              if (cfg.compositor == "hyprland" || config.desktop.hyprland.enable) then
                "${pkgs.hyprland}/bin/hyprctl dispatch dpms on"
              else
                "true";
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
