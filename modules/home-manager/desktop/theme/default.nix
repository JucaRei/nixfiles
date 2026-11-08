# What it is: Unified semantic theme engine (palette, GTK, icons, cursor, and fonts).
# How to enable: Set `desktop.theme.name = "..."; desktop.theme.accent = "...";` in settings.nix.
# Example: desktop.theme = { name = "catppuccin-mocha"; accent = "blue"; };
#
# desktop.theme — tema agnóstico (paleta + GTK + ícones + cursor + fonte).
#
# Uso (em qualquer host, com qualquer desktop):
#   desktop.theme = { enable = true; name = "dracula"; accent = "purple"; };
#
# Os módulos consomem as cores por papéis semânticos, sem depender do tema:
#   config.desktop.theme.colors.bg / .fg / .accent / .red ...
#   config.desktop.theme.colorsBare.bg   # sem "#" (ex.: Hyprland rgb())
#
# Nova paleta: crie palettes/<nome>.nix (ver palettes/dracula.nix). Nada mais a registrar.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkDefault
    mkMerge
    types
    ;
  cfg = config.desktop.theme;

  themeLib = import ./lib.nix { inherit lib; };

  accents = [
    "red"
    "orange"
    "yellow"
    "green"
    "teal"
    "cyan"
    "blue"
    "purple"
    "pink"
  ];

  loadPalettes = accent: import ./palettes { inherit lib pkgs accent; };
  paletteMap = loadPalettes cfg.accent;
  paletteNames = lib.unique (builtins.attrNames (loadPalettes "blue") ++ [ "tokyonight" ]);
  resolvedName = if cfg.name == "tokyonight" then "tokyo-night" else cfg.name;
  hasTheme = cfg.custom != null || (builtins.hasAttr resolvedName paletteMap);
  selectedPalette =
    if hasTheme then
      paletteMap.${resolvedName}
    else
      {
        label = resolvedName;
        variant = "dark";
        colors = { };
        gtk = null;
        icons = null;
        cursor = null;
      };

  palette =
    if cfg.custom != null then
      {
        label = cfg.custom.label;
        variant = cfg.custom.variant;
        colors = cfg.custom.colors;
        gtk = if cfg.custom.gtk != null then cfg.custom.gtk else selectedPalette.gtk;
        icons = if cfg.custom.icons != null then cfg.custom.icons else selectedPalette.icons;
        cursor = if cfg.custom.cursor != null then cfg.custom.cursor else selectedPalette.cursor;
      }
    else
      selectedPalette;

  paletteName = if cfg.custom != null then cfg.custom.label else cfg.name;

  withOverrides = palette.colors // cfg.overrides;

  fallbackColors = {
    bg = "#000000";
    bgAlt = "#000000";
    bgDark = "#000000";
    surface = "#000000";
    surfaceAlt = "#000000";
    border = "#000000";
    fg = "#ffffff";
    fgMuted = "#ffffff";
    fgSubtle = "#ffffff";
    red = "#ff0000";
    orange = "#ff8800";
    yellow = "#ffff00";
    green = "#00ff00";
    teal = "#00ffff";
    cyan = "#0088ff";
    blue = "#0000ff";
    purple = "#8800ff";
    pink = "#ff0088";
    accent = "#0000ff";
  };

  rawColors =
    let
      accentColor =
        cfg.overrides.accent or withOverrides.${cfg.accent} or withOverrides.blue or fallbackColors.accent;
    in
    fallbackColors // withOverrides // { accent = accentColor; };

  # Camada única de compatibilidade: aliases Catppuccin calculados uma vez para todas as paletas
  colors = rawColors // {
    lavender = rawColors.lavender or rawColors.purple or "#000000";
    sapphire = rawColors.sapphire or rawColors.blue or "#000000";
    sky = rawColors.sky or rawColors.cyan or "#000000";
    maroon = rawColors.maroon or rawColors.red or "#000000";
    peach = rawColors.peach or rawColors.orange or "#000000";
    mauve = rawColors.mauve or rawColors.purple or "#000000";
    flamingo = rawColors.flamingo or rawColors.pink or "#000000";
    rosewater = rawColors.rosewater or rawColors.pink or "#000000";
    subtext1 = rawColors.subtext1 or rawColors.fgMuted or "#000000";
    subtext0 = rawColors.subtext0 or rawColors.fgMuted or "#000000";
    overlay2 = rawColors.overlay2 or rawColors.fgSubtle or "#000000";
    overlay1 = rawColors.overlay1 or rawColors.fgSubtle or "#000000";
    overlay0 = rawColors.overlay0 or rawColors.fgSubtle or "#000000";
    surface2 = rawColors.surface2 or rawColors.surfaceAlt or "#000000";
    surface1 = rawColors.surface1 or rawColors.surface or "#000000";
    surface0 = rawColors.surface0 or rawColors.surface or "#000000";
    base = rawColors.base or rawColors.bg or "#000000";
    mantle = rawColors.mantle or rawColors.bgDark or "#000000";
    crust = rawColors.crust or rawColors.bgDark or "#000000";
    text = rawColors.text or rawColors.fg or "#000000";
  };

  requiredRoles = [
    "bg"
    "bgAlt"
    "bgDark"
    "surface"
    "surfaceAlt"
    "border"
    "fg"
    "fgMuted"
    "fgSubtle"
    "red"
    "orange"
    "yellow"
    "green"
    "teal"
    "cyan"
    "blue"
    "purple"
    "pink"
  ];

  missingRoles = builtins.filter (role: !withOverrides ? ${role}) requiredRoles;
  invalidColorFormat = builtins.filter (
    role:
    withOverrides ? ${role}
    && !(lib.isString withOverrides.${role} && lib.hasPrefix "#" withOverrides.${role})
  ) requiredRoles;

  registeredTargets = [
    "alacritty"
    "bat"
    "btop"
    "dunst"
    "eza"
    "fastfetch"
    "firefox"
    "fzf"
    "gedit"
    "gtk"
    "hyprland"
    "kitty"
    "mangowm"
    "meld"
    "mpv"
    "noctalia"
    "polybar"
    "qt"
    "rofi"
    "starship"
    "thunar"
    "urxvt"
    "vesktop"
    "vscode"
    "waybar"
    "wlogout"
    "wofi"
    "xsettingsd"
    "zathura"
    "zsh"
  ];

  assetOptions = {
    name = mkOption {
      type = types.str;
      description = "Nome do tema (diretório em share/themes ou share/icons).";
    };
    package = mkOption {
      type = types.package;
      description = "Pacote que fornece o tema.";
    };
    aliases =
      lib.my.mkListOf types.str [ ]
        "Nomes alternativos que também apontam para o mesmo tema (symlinks).";
  };

  # name + package (+ aliases), com o default vindo da paleta escolhida
  assetOption =
    default: description:
    lib.my.mkOpt (types.submodule { options = assetOptions; }) default description;

  isDark = palette.variant == "dark";

  # <base>/<nome> -> <pacote>/share/<sub>/<nome> para o nome e cada alias
  linkTheme =
    base: sub: asset:
    lib.genAttrs (map (n: "${base}/${n}") ([ asset.name ] ++ asset.aliases)) (_: {
      source = mkDefault "${asset.package}/share/${sub}/${asset.name}";
    });
in
{
  options.desktop.theme = {
    enable = mkEnableOption "aplicação do tema (GTK, ícones, cursor, fonte) neste host";

    name =
      lib.my.mkEnumEx paletteNames "catppuccin-mocha"
        "Paleta. Uma por arquivo em desktop/theme/palettes/."
        "catppuccin-mocha";

    accent =
      lib.my.mkEnumEx accents "blue"
        "Papel de cor usado como destaque (`colors.accent`) e, no Catppuccin, no tema GTK."
        "blue";

    custom =
      lib.my.mkOpt
        (types.nullOr (
          types.submodule {
            options = {
              label = lib.my.mkStr "Custom" "Nome descritivo da paleta customizada.";
              variant = lib.my.mkEnum [ "dark" "light" ] "dark" "Variante clara ou escura da paleta.";
              colors = mkOption {
                type = types.attrsOf types.str;
                description = "Conjunto completo de papéis de cor (\"#rrggbb\"). Deve incluir os papéis obrigatórios.";
              };
              gtk = lib.my.mkOpt (types.nullOr (
                types.submodule { options = assetOptions; }
              )) null "Tema GTK (opcional; se omitido, usa o da paleta padrão).";
              icons = lib.my.mkOpt (types.nullOr (
                types.submodule { options = assetOptions; }
              )) null "Tema de ícones (opcional; se omitido, usa o da paleta padrão).";
              cursor = lib.my.mkOpt (types.nullOr (
                types.submodule {
                  options = assetOptions // {
                    size = lib.my.mkInt 24 "Tamanho do cursor em pixels.";
                  };
                }
              )) null "Tema de cursor (opcional; se omitido, usa o da paleta padrão).";
            };
          }
        ))
        null
        "Paleta inline completa (sem arquivo). Quando definida, substitui a paleta de desktop.theme.name.";

    overrides =
      lib.my.mkOptEx (types.attrsOf types.str) { }
        "Sobrescritas pontuais de papéis de cores (ex.: { bg = \"#1e1e2e\"; border = \"#ff0000\"; }). Aplicadas sobre a paleta ativa."
        {
          bg = "#1e1e2e";
          border = "#ff0000";
        };

    exclude =
      lib.my.mkListOf types.str [ ]
        "Lista de alvos que não devem receber o tema automático (ex.: [ \"bat\" \"vscode\" ]).";

    gtk = assetOption palette.gtk "Tema GTK.";
    icons = assetOption palette.icons "Tema de ícones.";

    cursor = lib.my.mkOpt (types.submodule {
      options = assetOptions // {
        size = lib.my.mkInt 24 "Tamanho do cursor em pixels.";
      };
    }) palette.cursor "Tema de cursor.";

    font = lib.my.mkOpt (types.submodule {
      options = {
        name = lib.my.mkStr "Inter" "Nome da família de fonte.";
        package = lib.my.mkPkg pkgs.inter "Pacote que fornece a fonte.";
        size = lib.my.mkInt 10 "Tamanho da fonte em pontos.";
      };
    }) { } "Fonte da interface (GTK).";

    xsettingsd = {
      enable = lib.my.mkBool false "Ativar serviço e configuração do xsettingsd para ambientes X11.";
    };

    targets = mkOption {
      type = types.attrsOf types.bool;
      readOnly = true;
      description = "Registro único de alvos de tema. Cada alvo é booleano (true se ativo para receber o tema, false se listado em desktop.theme.exclude).";
    };

    # Somente leitura: calculados a partir da paleta
    colors = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      description = "Cores da paleta (\"#rrggbb\"). Papéis: bg bgAlt bgDark surface surfaceAlt border fg fgMuted fgSubtle red orange yellow green teal cyan blue purple pink accent (+ extras específicos da paleta).";
    };
    colorsBare = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      description = "Mesmas cores sem o \"#\" (formato rrggbb).";
    };
    variant = mkOption {
      type = types.enum [
        "dark"
        "light"
      ];
      readOnly = true;
      description = "Claro ou escuro, conforme a paleta.";
    };

    lib = mkOption {
      type = types.attrsOf types.anything;
      readOnly = true;
      description = "Helpers utilitários de cor e geração de temas (rgb, rgba, cssRgb, cssRgba, hexTo0x, hexToTuple, withAlpha, generateTmTheme).";
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = hasTheme;
          message = "desktop.theme: O tema '${cfg.name}' não existe. Temas válidos disponíveis: ${lib.concatStringsSep ", " paletteNames}. Dica: execute './scripts/nx themes' para ver a lista.";
        }
        {
          assertion = missingRoles == [ ];
          message = "desktop.theme: A paleta '${paletteName}' não define todos os papéis obrigatórios de cor. Papéis ausentes: ${lib.concatStringsSep ", " missingRoles}. Papéis obrigatórios: ${lib.concatStringsSep ", " requiredRoles}.";
        }
        {
          assertion = invalidColorFormat == [ ];
          message = "desktop.theme: Os seguintes papéis de cor na paleta '${paletteName}' devem ser strings hexadecimais no formato '#rrggbb': ${lib.concatStringsSep ", " invalidColorFormat}.";
        }
      ];

      desktop.theme = {
        inherit colors;
        colorsBare = lib.mapAttrs (_: lib.removePrefix "#") colors;
        inherit (palette) variant;
        targets = lib.genAttrs (lib.unique (registeredTargets ++ cfg.exclude)) (
          name: !(builtins.elem name cfg.exclude)
        );
        lib = themeLib;
      };
    }

    # mkDefault em tudo: blocos antigos por ambiente continuam vencendo durante a migração.
    (import ./_gtk-targets.nix {
      inherit
        config
        lib
        pkgs
        cfg
        palette
        paletteName
        colors
        isDark
        linkTheme
        ;
    })
  ];
}
