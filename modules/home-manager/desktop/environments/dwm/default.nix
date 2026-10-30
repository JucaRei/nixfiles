{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = lib.my.importDir ./.;

  config = lib.mkIf config.desktop.dwm.enable {
    desktop.display-servers.backend = "x11";
    desktop.theme.xsettingsd.enable = lib.mkDefault true;

    # Programas Padrão integrados
    system.programs = {
      terminal = {
        enable = lib.mkDefault true;
        name = lib.mkDefault "alacritty";
      };
      file-manager = {
        default = lib.mkDefault "thunar";
        thunar.enable = lib.mkDefault (
          !config.system.programs.file-manager.nautilus.enable
          && !config.system.programs.file-manager.nemo.enable
          && !config.system.programs.file-manager.pcmanfm.enable
        );
      };
      tools.flameshot.enable = true;
      documents.zathura.enable = true;
    };

    # Desativar geração de symlinks read-only do settings.ini pelo Home Manager
    # para permitir que o motor de temas do dwm-titus (theme-apply.sh e QML) edite os arquivos
    gtk.enable = lib.mkForce false;

    home.packages = [
      config.desktop.theme.gtk.package
      config.desktop.theme.icons.package
      config.desktop.theme.cursor.package
      pkgs.cantarell-fonts
    ];

    xresources.properties = {
      "Xcursor.theme" = config.desktop.theme.cursor.name;
      "Xcursor.size" = config.desktop.theme.cursor.size;
    };
  };
}
