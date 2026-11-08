# Declarative desktop settings options for NixOS hosts.
# Consumed by integrated Home Manager via osConfig.desktop.
{ lib, ... }:
{
  options.desktop = {
    theme = {
      name = lib.my.mkStr "catppuccin-mocha" "Nome do tema desktop para o Home Manager.";
      accent = lib.my.mkStr "blue" "Papel de cor de destaque para o Home Manager.";
    };
    modifierKey = lib.my.mkStr "Super" "Tecla modificadora principal (Super ou Alt).";
    wallpaper = {
      directory =
        lib.my.mkOpt (lib.types.nullOr lib.types.str) null
          "Caminho do diretório de papéis de parede para o Home Manager.";
    };
    monitors =
      lib.my.mkListOf (lib.types.attrsOf lib.types.anything) [ ]
        "Lista de monitores para o Home Manager.";
  };
}
