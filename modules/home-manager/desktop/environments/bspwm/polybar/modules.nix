{
  lib,
  pkgs,
  colors,
  scripts,
  cfg ? {
    battery = "BAT0";
    adapter = "ADP1";
    encapsulation = "pill";
    tray = {
      enable = false;
    };
  },
  ...
}:
let
  rawDefault =
    if builtins.isAttrs (cfg.encapsulation or null) then
      cfg.encapsulation.default or "pill"
    else
      cfg.encapsulation or "pill";

  rawEncap = if builtins.isAttrs rawDefault then rawDefault.style or "pill" else rawDefault;

  resolveColor =
    val: defaultVal:
    if val == null || val == "" then
      defaultVal
    else if lib.strings.hasPrefix "#" val then
      val
    else
      colors.${val} or (
        if
          builtins.match "^[0-9a-fA-F]{6}$" val != null || builtins.match "^[0-9a-fA-F]{8}$" val != null
        then
          "#${val}"
        else
          defaultVal
      );

  customGlyphColor =
    if builtins.isAttrs (cfg.encapsulation or null) then
      resolveColor (cfg.encapsulation.colors.glyph or cfg.encapsulation.colors.default
        or cfg.encapsulation.color or (
          if builtins.isAttrs (cfg.encapsulation.default or null) then
            cfg.encapsulation.default.color or null
          else
            null
        )
      ) colors.pill
    else
      colors.pill;

  encapType =
    if rawEncap != "pill" then
      rawEncap
    else if (cfg.style or "") == "shapes" then
      "shapes"
    else
      "pill";

  encapGlyphs = {
    pill = {
      left = "";
      right = "";
    };
    shapes = {
      left = "";
      right = "";
    };
    slant = {
      left = "";
      right = "";
    };
    powerline = {
      left = "";
      right = "";
    };
  };

  currentEncap = encapGlyphs.${encapType} or encapGlyphs.pill;

  commonArgs = {
    inherit
      lib
      pkgs
      colors
      scripts
      cfg
      ;
  };

  encapModules = import ./modules/encap.nix {
    inherit
      lib
      colors
      customGlyphColor
      currentEncap
      ;
  };

  workspacesModules = import ./modules/workspaces.nix commonArgs;
  mediaModules = import ./modules/media.nix commonArgs;
  systemModules = import ./modules/system.nix commonArgs;
  networkModules = import ./modules/network.nix commonArgs;

  baseModules = {
    # --- Divisores & Espaçadores Elegantes (Estilo Waybar / Catppuccin) ---
    "module/sep" = {
      type = "custom/text";
      format = "<label>";
      label = "  %{F${colors.surface1}}│%{F-}  ";
    };

    "module/dots" = {
      type = "custom/text";
      format = "<label>";
      label = "  %{F${colors.surface1}}·%{F-}  ";
    };

    # --- Lançador de Aplicativos (Logo do Sistema Operacional) ---
    "module/launcher" = {
      type = "custom/script";
      exec = "${scripts.osLogoScript}";
      interval = 3600;
      format = "%{A1:${pkgs.rofi}/bin/rofi -show drun:}<label>%{A}";
      label = "%output%";
      label-font = 4;
      label-padding = 1;
      click-left = "${pkgs.rofi}/bin/rofi -show drun";
    };
  };
in
baseModules // encapModules // workspacesModules // mediaModules // systemModules // networkModules
