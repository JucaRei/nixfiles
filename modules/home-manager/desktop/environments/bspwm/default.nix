{
  config,
  lib,
  ...
}:
{
  imports = [
    ./bspwm.nix
    ./sxhkd.nix
    ./polybar
    ./picom.nix
    ./dunst.nix
    ./rofi.nix
    ./packages.nix
    ./lock.nix
  ];

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
