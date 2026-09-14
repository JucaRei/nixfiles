{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.wayland;
  isTraditional = config.desktop.display-servers.backend == "wayland" && cfg.shell == "traditional";
in
{
  options.desktop.wayland.traditional.hyprlock = {
    enable = mkOption {
      type = bool;
      default = isTraditional;
      description = "Habilitar hyprlock lockscreen para o shell tradicional Wayland";
    };
  };

  # Retrocompatibilidade
  options.desktop.hyprland.hyprlock = {
    enable = mkOption {
      type = bool;
      default = config.desktop.wayland.traditional.hyprlock.enable;
      description = "Opção de retrocompatibilidade para hyprlock";
    };
  };

  config = mkIf (isTraditional && config.desktop.wayland.traditional.hyprlock.enable) {
    programs.hyprlock = {
      enable = true;
      package = pkgs.hyprlock;
      settings = {
        general = {
          hide_cursor = true;
        };

        background = [
          {
            monitor = "";
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
            noise = 0.0117;
            contrast = 0.8916;
            brightness = 0.8172;
            vibrancy = 0.1696;
            vibrancy_darkness = 0.0;
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "280, 52";
            outline_thickness = 2;
            dots_size = 0.22;
            dots_spacing = 0.2;
            dots_center = true;
            outer_color = "rgba(203, 166, 247, 1.0)"; # Mauve
            inner_color = "rgba(24, 24, 37, 0.85)"; # Mantle
            font_color = "rgb(205, 214, 244)"; # Text
            fade_on_empty = false;
            placeholder_text = "<i>Digite sua senha...</i>";
            hide_input = false;
            check_color = "rgba(137, 180, 250, 1.0)"; # Blue
            fail_color = "rgba(243, 139, 168, 1.0)"; # Red
            fail_text = "<i>Falha na autenticação ($ATTEMPTS)</i>";
            position = "0, -90";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          # Relógio Grande
          {
            monitor = "";
            text = "$TIME";
            color = "rgba(205, 214, 244, 0.95)";
            font_size = 80;
            font_family = "Inter Bold";
            position = "0, 130";
            halign = "center";
            valign = "center";
          }
          # Data
          {
            monitor = "";
            text = "cmd[update:1000] echo \"$(date +'%A, %d de %B de %Y')\"";
            color = "rgba(166, 173, 200, 0.9)";
            font_size = 18;
            font_family = "Inter Medium";
            position = "0, 50";
            halign = "center";
            valign = "center";
          }
          # Saudação com Usuário
          {
            monitor = "";
            text = "Olá, $USER";
            color = "rgba(203, 166, 247, 0.95)";
            font_size = 20;
            font_family = "Inter SemiBold";
            position = "0, -20";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
