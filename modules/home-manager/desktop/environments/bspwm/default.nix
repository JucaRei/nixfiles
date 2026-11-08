# What it is: BSPWM tiling window manager environment with sxhkd and polybar.
# How to enable: Set `desktop = "bspwm";` in hosts.nix or `desktop.bspwm.enable = true;`.
# Example: desktop.bspwm.enable = true;
{
  config,
  lib,
  ...
}:
{
  imports = lib.my.importDir ./.;

  config = lib.mkIf config.desktop.bspwm.enable {
    desktop.display-servers.backend = "x11";
    desktop.theme.xsettingsd.enable = lib.mkDefault true;

    # --- Programas Padrão do BSPWM ---
    system.programs = {
      file-manager.thunar.enable = lib.mkDefault (
        !config.system.programs.file-manager.nautilus.enable
        && !config.system.programs.file-manager.nemo.enable
        && !config.system.programs.file-manager.pcmanfm.enable
      );
    };

    xresources.properties = {
      "Xcursor.theme" = config.desktop.theme.cursor.name;
      "Xcursor.size" = config.desktop.theme.cursor.size;
    };

    dconf.settings = {
      "org/blueman/general" = {
        notification-daemon = true;
        plugin-list = [ "!StatusIcon" ];
      };
    };
  };
}
