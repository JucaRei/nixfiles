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
  imports = [
    ./waybar.nix
    ./rofi.nix
    ./dunst.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
  ];

  options.desktop.wayland.traditional = {
    enable = lib.my.mkBool isTraditional "Habilitar conjunto de componentes do Shell Tradicional para Wayland (Waybar, Rofi, Dunst, Hyprlock, Hypridle, Hyprpaper)";
  };

  config = mkIf isTraditional {
    desktop.wayland.traditional.enable = true;
  };
}
