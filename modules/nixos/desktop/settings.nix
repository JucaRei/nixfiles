# Bridge module exposing desktop settings in NixOS for integrated Home Manager.
{
  config,
  lib,
  username ? "juca",
  ...
}:
let
  cfg = config.desktop;
in
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

  config = lib.mkIf (config ? home-manager && config.home-manager.users ? ${username}) {
    home-manager.users.${username} = {
      desktop = {
        theme = {
          name = lib.mkDefault cfg.theme.name;
          accent = lib.mkDefault cfg.theme.accent;
        };
        modifierKey = lib.mkDefault cfg.modifierKey;
        wallpaper.directory = lib.mkDefault cfg.wallpaper.directory;
        monitors = lib.mkDefault cfg.monitors;
      };
    };
  };
}
