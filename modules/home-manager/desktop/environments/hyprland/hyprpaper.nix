{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.hyprland.hyprpaper;

  defaultWallpaper = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
in
{
  options.desktop.hyprland.hyprpaper = {
    enable = mkOption {
      type = bool;
      default = config.desktop.hyprland.enable;
      description = "Enable hyprpaper wallpaper daemon for hyprland";
    };
  };

  config = mkIf cfg.enable {
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
