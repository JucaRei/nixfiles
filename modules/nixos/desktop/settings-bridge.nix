# Declarative desktop settings bridge for NixOS hosts.
# Consumed by integrated Home Manager via osConfig.desktop.
{ lib, ... }:
{
  options.desktop = {
    theme = {
      name =
        lib.my.mkOptEx (lib.types.nullOr lib.types.str) null "Nome do tema desktop para o Home Manager."
          "catppuccin-mocha";
      accent =
        lib.my.mkOptEx (lib.types.nullOr lib.types.str) null "Papel de cor de destaque para o Home Manager."
          "blue";
    };
    modifierKey =
      lib.my.mkOptEx (lib.types.nullOr lib.types.str) null "Tecla modificadora principal (Super ou Alt)."
        "Super";
    wallpaper = {
      directory =
        lib.my.mkOptEx (lib.types.nullOr lib.types.str) null
          "Caminho do diretório de papéis de parede para o Home Manager."
          "/home/juca/Pictures/Wallpapers";
    };
    monitors =
      lib.my.mkOptEx (lib.types.nullOr (lib.types.listOf (lib.types.attrsOf lib.types.anything))) null
        "Lista de monitores para o Home Manager."
        [
          {
            name = "eDP-1";
            width = 1920;
            height = 1080;
            refresh = 60;
            primary = true;
          }
        ];
  };
}
