{
  lib,
  cfg,
  colors,
}:
let
  isPills = cfg.style == "zproger" || cfg.style == "pills" || cfg.style == "shapes";
  hasTray = cfg.tray.enable;

  # Resolução e normalização granular de cada encapsulamento (style, color, accent)
  normalizeEncap =
    item: defaultStyle:
    if builtins.isAttrs item then
      {
        style = if (item.style or "default") != "default" then item.style else defaultStyle;
        color = item.color or null;
        accent = item.accent or null;
      }
    else if builtins.isString item && item != "default" then
      {
        style = item;
        color = null;
        accent = null;
      }
    else
      {
        style = defaultStyle;
        color = null;
        accent = null;
      };

  baseDefaultStyle = if cfg.style == "shapes" then "shapes" else "pill";

  defaultEncapObj =
    if builtins.isAttrs cfg.encapsulation then
      normalizeEncap (cfg.encapsulation.default or baseDefaultStyle) baseDefaultStyle
    else if builtins.isString cfg.encapsulation && cfg.encapsulation != "pill" then
      normalizeEncap cfg.encapsulation baseDefaultStyle
    else
      normalizeEncap baseDefaultStyle baseDefaultStyle;

  getEncapConfig =
    specific:
    if builtins.isAttrs cfg.encapsulation then
      normalizeEncap (cfg.encapsulation.${specific} or "default") defaultEncapObj.style
    else
      defaultEncapObj;

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

  encapColors = if builtins.isAttrs cfg.encapsulation then (cfg.encapsulation.colors or { }) else { };

  globalEncapColor =
    if builtins.isAttrs cfg.encapsulation then
      (
        if cfg.encapsulation.color != null then
          cfg.encapsulation.color
        else if defaultEncapObj.color != null then
          defaultEncapObj.color
        else
          null
      )
    else
      null;

  globalAccentFallback =
    if colors ? pill-active && colors.pill-active != "" then colors.pill-active else colors.accent;

  globalAccent = resolveColor (
    if builtins.isAttrs cfg.encapsulation then
      (
        if cfg.encapsulation.accent != null then
          cfg.encapsulation.accent
        else if encapColors ? accent && encapColors.accent != null then
          encapColors.accent
        else if defaultEncapObj.accent != null then
          defaultEncapObj.accent
        else
          null
      )
    else
      null
  ) globalAccentFallback;

  baseGlyphColor = resolveColor (encapColors.glyph or encapColors.default or globalEncapColor
  ) colors.pill;

  wsEncapCfg = getEncapConfig "workspaces";
  statsEncapCfg = getEncapConfig "stats";
  netspeedEncapCfg = getEncapConfig "netspeed";
  dateEncapCfg = getEncapConfig "date";
  trayEncapCfg = getEncapConfig "tray";

  wsColor = resolveColor (
    if wsEncapCfg.color != null then wsEncapCfg.color else encapColors.workspaces or null
  ) baseGlyphColor;
  statsColor = resolveColor (
    if statsEncapCfg.color != null then statsEncapCfg.color else encapColors.stats or null
  ) baseGlyphColor;
  netspeedColor = resolveColor (
    if netspeedEncapCfg.color != null then netspeedEncapCfg.color else encapColors.netspeed or null
  ) baseGlyphColor;
  dateColor = resolveColor (
    if dateEncapCfg.color != null then dateEncapCfg.color else encapColors.date or null
  ) baseGlyphColor;
  trayColor = resolveColor (
    if trayEncapCfg.color != null then trayEncapCfg.color else encapColors.tray or null
  ) baseGlyphColor;

  focusedWsColor = resolveColor (
    if wsEncapCfg.accent != null then
      wsEncapCfg.accent
    else if encapColors ? workspacesAccent && encapColors.workspacesAccent != null then
      encapColors.workspacesAccent
    else if encapColors ? focused && encapColors.focused != null then
      encapColors.focused
    else if encapColors ? active && encapColors.active != null then
      encapColors.active
    else
      null
  ) globalAccent;
  focusedNumColor = resolveColor (encapColors.focusedNumber or encapColors.focused_number or null
  ) colors.dark;

  statsAccent = resolveColor (
    if statsEncapCfg.accent != null then statsEncapCfg.accent else encapColors.statsAccent or null
  ) null;
  cpuIconColor = if statsAccent != null then statsAccent else colors.purple;
  memIconColor = if statsAccent != null then statsAccent else colors.orange;
  tempIconColor = if statsAccent != null then statsAccent else colors.ice;
  diskIconColor = if statsAccent != null then statsAccent else colors.orange;

  netspeedAccent = resolveColor (
    if netspeedEncapCfg.accent != null then
      netspeedEncapCfg.accent
    else
      encapColors.netspeedAccent or null
  ) colors.nord;

  dateAccent = resolveColor (
    if dateEncapCfg.accent != null then dateEncapCfg.accent else encapColors.dateAccent or null
  ) colors.time-alt;

  trayAccent = resolveColor (
    if trayEncapCfg.accent != null then trayEncapCfg.accent else encapColors.trayAccent or null
  ) colors.blue-alt;

  wsEncap = wsEncapCfg.style;
  statsEncap = statsEncapCfg.style;
  netspeedEncap = netspeedEncapCfg.style;
  dateEncap = dateEncapCfg.style;
  trayEncap = trayEncapCfg.style;

  # Glifos mapeados para os módulos de encapsulamento dedicados
  encapGlyphMap = {
    pill = {
      left = "";
      right = "";
    };
    shapes = {
      left = "";
      right = "";
    };
    shape = {
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

  getGlyphs = e: encapGlyphMap.${e} or encapGlyphMap.pill;
  wsGlyphs = getGlyphs wsEncap;
  statsGlyphs = getGlyphs statsEncap;
  netspeedGlyphs = getGlyphs netspeedEncap;
  dateGlyphs = getGlyphs dateEncap;
  trayGlyphs = getGlyphs trayEncap;

  wsLeft = "encap-ws-left";
  wsRight = "encap-ws-right";
  statsLeft = "encap-stats-left";
  statsRight = "encap-stats-right";
  netspeedLeft = "encap-netspeed-left";
  netspeedRight = "encap-netspeed-right";
  dateLeft = "encap-date-left";
  dateRight = "encap-date-right";
  trayLeft = "encap-tray-left";
  trayRight = "encap-tray-right";

  # Overrides aplicados aos módulos existentes quando o estilo pills/zproger ou shapes está ativo.
  # 1. Workspaces com números coloridos pastel dentro da cápsula
  # 2. Playerctl/Media no centro, idêntico ao estilo moderno
  # 3. Módulos com ícone único sem duplicações (sem prefixos colidindo com scripts)
  # 4. Relógio dentro da cápsula com ícone único  em cinza suave

in
{
  inherit
    isPills
    hasTray
    wsColor
    focusedWsColor
    focusedNumColor
    statsColor
    cpuIconColor
    memIconColor
    tempIconColor
    diskIconColor
    netspeedColor
    netspeedAccent
    dateColor
    dateAccent
    trayColor
    trayAccent
    wsGlyphs
    statsGlyphs
    netspeedGlyphs
    dateGlyphs
    trayGlyphs
    wsLeft
    wsRight
    statsLeft
    statsRight
    netspeedLeft
    netspeedRight
    dateLeft
    dateRight
    trayLeft
    trayRight
    ;
}
