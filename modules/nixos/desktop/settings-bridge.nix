# Declarative desktop settings bridge for NixOS hosts.
# Consumed by integrated Home Manager via osConfig.desktop.
{ lib, ... }:
{
  options.desktop = {
    theme = {
      name =
        lib.my.mkOpt (lib.types.nullOr lib.types.str) null
          "Nome do tema desktop para o Home Manager.";
      accent =
        lib.my.mkOpt (lib.types.nullOr lib.types.str) null
          "Papel de cor de destaque para o Home Manager.";
    };
    modifierKey =
      lib.my.mkOpt (lib.types.nullOr lib.types.str) null
        "Tecla modificadora principal (Super ou Alt).";
    wallpaper = {
      directory =
        lib.my.mkOpt (lib.types.nullOr lib.types.str) null
          "Caminho do diretório de papéis de parede para o Home Manager.";
    };
    monitors = lib.my.mkOpt (lib.types.nullOr (
      lib.types.listOf (lib.types.attrsOf lib.types.anything)
    )) null "Lista de monitores para o Home Manager.";
  };
}
