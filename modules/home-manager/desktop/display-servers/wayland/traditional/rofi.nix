{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.wayland;
  isTraditional = config.desktop.display-servers.backend == "wayland" && cfg.shell == "traditional";
in
{
  options.desktop.wayland.traditional.rofi = {
    enable = lib.my.mkBool isTraditional "Habilitar launcher de aplicações Rofi para shell tradicional Wayland";
  };

  # Retrocompatibilidade com desktop.hyprland.rofi
  options.desktop.hyprland.rofi = {
    enable = lib.my.mkBool config.desktop.wayland.traditional.rofi.enable "Opção de retrocompatibilidade para rofi";
  };

  config = mkIf (isTraditional && config.desktop.wayland.traditional.rofi.enable) {
    desktop.shared.rofi = {
      enable = true;
      backend = "wayland";
    };
  };
}
