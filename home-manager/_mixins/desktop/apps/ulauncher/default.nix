{ config, desktop, lib, pkgs, ... }:
let
  user-themes = pkgs.lib.cleanSource ./user-themes;
  cfg = config.desktop.apps.ulauncher;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.desktop.apps.ulauncher = {
    enable = mkEnableOption "Enables ulauncher.";
  };

  config = mkIf (cfg.enable && desktop == "pantheon") {
    dconf.settings = with lib.hm.gvariant; {
      "org/pantheon/desktop/gala/behavior" = {
        overlay-action = "${pkgs.ulauncher}/bin/ulauncher-toggle";
      };
    };
    home = {
      file = {
        "${config.xdg.configHome}/ulauncher/settings.json".text = builtins.readFile ./settings.json;
        "${config.xdg.configHome}/ulauncher/user-themes/Catppuccin-Mocha-Blue" = {
          source = user-themes;
          recursive = true;
        };
        "${config.xdg.configHome}/autostart/ulauncher.desktop".text = ''
          [Desktop Entry]
          Name=uLauncher
          Comment=uLauncher
          Type=Application
          Exec=ulauncher --hide-window
          Icon=ulauncher
          Categories=
          Terminal=false
          StartupNotify=false'';
      };
      packages = with pkgs; [ ulauncher ];
    };
  };
}
