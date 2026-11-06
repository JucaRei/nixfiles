# modules/home-manager/desktop/environments/bspwm/options.nix
# Opções de configuração raiz do gerenciador de janelas BSPWM.
{
  config,
  lib,
  desktop ? null,
  ...
}:
{
  options.desktop.bspwm = {
    enable = lib.my.mkBool (desktop == "bspwm") "Enable bspwm window manager";

    extraConfig = lib.my.mkStr "" "Additional bspwmrc configuration to append";

    modifierKey = lib.my.mkStr (config.desktop.modifierKey or "Super"
    ) "Tecla modificadora principal do BSPWM (ex: 'Super', 'Alt', 'Ctrl').";

    extraKeybindings =
      lib.my.mkOpt (lib.types.attrsOf lib.types.str) { }
        "Atalhos adicionais ou personalizados do SXHKD definidos no host.";

    rules = lib.my.mkListOf lib.types.str [ ] "bspwm rules for specific applications";
  };
}

