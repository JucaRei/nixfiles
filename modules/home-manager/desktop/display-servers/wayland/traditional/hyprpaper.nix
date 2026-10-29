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

  defaultWallpaper = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
in
{
  options.desktop.wayland.traditional.hyprpaper = {
    enable = lib.my.mkBool isTraditional "Habilitar hyprpaper wallpaper daemon para o shell tradicional Wayland";
  };

  # Retrocompatibilidade
  options.desktop.hyprland.hyprpaper = {
    enable = lib.my.mkBool config.desktop.wayland.traditional.hyprpaper.enable "Opção de retrocompatibilidade para hyprpaper";
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
