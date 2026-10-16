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
    mkIf
    mkDefault
    mkMerge
    types
    ;
  cfg = config.desktop.theme;

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
  paletteNames = builtins.attrNames (loadPalettes "blue"); # só nomes: não força nenhum pacote
  palette = (loadPalettes cfg.accent).${cfg.name};
  colors = palette.colors // {
    accent = palette.colors.${cfg.accent};
  };

  assetOptions = {
    name = mkOption {
      type = types.str;
      description = "Nome do tema (diretório em share/themes ou share/icons).";
    };
    package = mkOption {
      type = types.package;
      description = "Pacote que fornece o tema.";
    };
    aliases = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Nomes alternativos que também apontam para o mesmo tema (symlinks).";
    };
  };

  # name + package (+ aliases), com o default vindo da paleta escolhida
  assetOption =
    default: description:
    mkOption {
      type = types.submodule { options = assetOptions; };
      inherit default description;
    };

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

    name = mkOption {
      type = types.enum paletteNames;
      default = "catppuccin-mocha";
      description = "Paleta. Uma por arquivo em desktop/theme/palettes/.";
    };

    accent = mkOption {
      type = types.enum accents;
      default = "blue";
      description = "Papel de cor usado como destaque (`colors.accent`) e, no Catppuccin, no tema GTK.";
    };

    gtk = assetOption palette.gtk "Tema GTK.";
    icons = assetOption palette.icons "Tema de ícones.";

    cursor = mkOption {
      type = types.submodule {
        options = assetOptions // {
          size = mkOption {
            type = types.int;
            default = 24;
          };
        };
      };
      default = palette.cursor;
      description = "Tema de cursor.";
    };

    font = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            default = "Inter";
          };
          package = mkOption {
            type = types.package;
            default = pkgs.inter;
          };
          size = mkOption {
            type = types.int;
            default = 10;
          };
        };
      };
      default = { };
      description = "Fonte da interface (GTK).";
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
  };

  config = mkMerge [
    {
      desktop.theme = {
        inherit colors;
        colorsBare = lib.mapAttrs (_: lib.removePrefix "#") colors;
        inherit (palette) variant;
      };
    }

    # mkDefault em tudo: blocos antigos por ambiente continuam vencendo durante a migração.
    (mkIf cfg.enable {
      gtk = {
        enable = mkDefault true;
        colorScheme = mkDefault cfg.variant;
        theme = mkDefault { inherit (cfg.gtk) name package; };
        iconTheme = mkDefault { inherit (cfg.icons) name package; };
        cursorTheme = mkDefault { inherit (cfg.cursor) name package size; };
        font = mkDefault { inherit (cfg.font) name package size; };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = mkDefault (if isDark then 1 else 0);
          gtk-cursor-theme-size = mkDefault cfg.cursor.size;
        };
        gtk4 = {
          theme = mkDefault config.gtk.theme;
          extraConfig.gtk-application-prefer-dark-theme = mkDefault (if isDark then 1 else 0);
        };
      };

      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = mkDefault (if isDark then "prefer-dark" else "prefer-light");
        gtk-theme = mkDefault cfg.gtk.name;
        icon-theme = mkDefault cfg.icons.name;
        cursor-theme = mkDefault cfg.cursor.name;
        cursor-size = mkDefault cfg.cursor.size;
        font-name = mkDefault "${cfg.font.name} ${toString cfg.font.size}";
      };

      home = {
        sessionVariables = {
          GTK_THEME = mkDefault cfg.gtk.name;
          XCURSOR_THEME = mkDefault cfg.cursor.name;
          XCURSOR_SIZE = mkDefault (toString cfg.cursor.size);
        };

        # Symlinks para apps que não leem o perfil do Home Manager (Flatpak, Qt, WMs puros)
        file =
          linkTheme ".themes" "themes" cfg.gtk
          // linkTheme ".local/share/themes" "themes" cfg.gtk
          // linkTheme ".icons" "icons" cfg.cursor
          // linkTheme ".local/share/icons" "icons" cfg.cursor
          // {
            ".icons/default/index.theme".text = mkDefault ''
              [Icon Theme]
              Name=Default
              Comment=Default Cursor Theme
              Inherits=${cfg.cursor.name}
            '';
          };
      };
    })
  ];
}
