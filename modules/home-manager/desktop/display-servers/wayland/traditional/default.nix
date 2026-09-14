{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.wayland;
  isTraditional = config.desktop.display-servers.backend == "wayland" && cfg.shell == "traditional";
in
{
  imports = [
    ./waybar.nix
    ./rofi.nix
    ./dunst.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
  ];

  options.desktop.wayland.traditional = {
    enable = mkOption {
      type = bool;
      default = isTraditional;
      description = "Habilitar conjunto de componentes do Shell Tradicional para Wayland (Waybar, Rofi, Dunst, Hyprlock, Hypridle, Hyprpaper)";
    };
  };

  config = mkIf isTraditional {
    desktop.wayland.traditional.enable = true;
  };
}
