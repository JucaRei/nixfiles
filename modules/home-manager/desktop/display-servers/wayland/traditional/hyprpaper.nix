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

  defaultWallpaper = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
in
{
  options.desktop.wayland.traditional.hyprpaper = {
    enable = mkOption {
      type = bool;
      default = isTraditional;
      description = "Habilitar hyprpaper wallpaper daemon para o shell tradicional Wayland";
    };
  };

  # Retrocompatibilidade
  options.desktop.hyprland.hyprpaper = {
    enable = mkOption {
      type = bool;
      default = config.desktop.wayland.traditional.hyprpaper.enable;
      description = "Opção de retrocompatibilidade para hyprpaper";
    };
  };

  config = mkIf (isTraditional && config.desktop.wayland.traditional.hyprpaper.enable) {
    services.hyprpaper = {
      enable = true;
      package = pkgs.hyprpaper;
      settings = {
        ipc = "on";
        splash = false;
        preload = [ "${defaultWallpaper}" ];
        wallpaper = [ ",${defaultWallpaper}" ];
      };
    };
  };
}
