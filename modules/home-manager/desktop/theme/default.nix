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
  paletteNames = lib.unique (builtins.attrNames (loadPalettes "blue") ++ [ "tokyonight" ]);
  resolvedName = if cfg.name == "tokyonight" then "tokyo-night" else cfg.name;
  palette = (loadPalettes cfg.accent).${resolvedName};
  rawColors = palette.colors // {
    accent = palette.colors.${cfg.accent};
  };

  # Camada única de compatibilidade: aliases Catppuccin calculados uma vez para todas as paletas
  colors = rawColors // {
    lavender = rawColors.lavender or rawColors.purple;
    sapphire = rawColors.sapphire or rawColors.blue;
    sky = rawColors.sky or rawColors.cyan;
    maroon = rawColors.maroon or rawColors.red;
    peach = rawColors.peach or rawColors.orange;
    mauve = rawColors.mauve or rawColors.purple;
    flamingo = rawColors.flamingo or rawColors.pink;
    rosewater = rawColors.rosewater or rawColors.pink;
    subtext1 = rawColors.subtext1 or rawColors.fgMuted;
    subtext0 = rawColors.subtext0 or rawColors.fgMuted;
    overlay2 = rawColors.overlay2 or rawColors.fgSubtle;
    overlay1 = rawColors.overlay1 or rawColors.fgSubtle;
    overlay0 = rawColors.overlay0 or rawColors.fgSubtle;
    surface2 = rawColors.surface2 or rawColors.surfaceAlt;
    surface1 = rawColors.surface1 or rawColors.surface;
    surface0 = rawColors.surface0 or rawColors.surface;
    base = rawColors.base or rawColors.bg;
    mantle = rawColors.mantle or rawColors.bgDark;
    crust = rawColors.crust or rawColors.bgDark;
    text = rawColors.text or rawColors.fg;
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

    xsettingsd = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Ativar serviço e configuração do xsettingsd para ambientes X11.";
      };
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

      xresources.properties = {
        "Xcursor.theme" = mkDefault cfg.cursor.name;
        "Xcursor.size" = mkDefault cfg.cursor.size;
      };

      # Configuração declarativa para xsettingsd (gerenciador XSETTINGS leve para X11/BSPWM/DWM)
      xdg.configFile = mkIf cfg.xsettingsd.enable {
        "xsettingsd/xsettingsd.conf".text = mkDefault ''
          Net/ThemeName "${cfg.gtk.name}"
          Gtk/ThemeName "${cfg.gtk.name}"
          Net/IconThemeName "${cfg.icons.name}"
          Gtk/CursorThemeName "${cfg.cursor.name}"
          Gtk/CursorThemeSize ${toString cfg.cursor.size}
          Gtk/FontName "${cfg.font.name} ${toString cfg.font.size}"
          Gtk/ApplicationPreferDarkTheme ${if isDark then "1" else "0"}
          Gtk/DecorationLayout ":minimize,maximize,close"
          Net/EnableEventSounds 0
          Net/EnableInputFeedbackSounds 0
          Xft/Antialias 1
          Xft/Hinting 1
          Xft/HintStyle "hintslight"
          Xft/RGBA "rgb"
        '';
      };

      # Serviço de usuário do Systemd para xsettingsd no X11
      systemd.user.services.xsettingsd = mkIf cfg.xsettingsd.enable {
        Unit = {
          Description = "XSettings Daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.xsettingsd}/bin/xsettingsd";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      home = {
        sessionVariables = {
          GTK_THEME = mkDefault cfg.gtk.name;
          XCURSOR_THEME = mkDefault cfg.cursor.name;
          XCURSOR_SIZE = mkDefault (toString cfg.cursor.size);
        };

        # Recarrega o xsettingsd e sincroniza variáveis de sessão na sessão gráfica atual
        activation.reloadXsettings = mkIf cfg.xsettingsd.enable (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ -n "''${DISPLAY:-}" ]; then
              ${pkgs.procps}/bin/pkill -HUP -x xsettingsd 2>/dev/null || true
              if command -v ${pkgs.dbus}/bin/dbus-update-activation-environment >/dev/null 2>&1; then
                ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd GTK_THEME XCURSOR_THEME XCURSOR_SIZE 2>/dev/null || true
              fi
              if command -v systemctl >/dev/null 2>&1; then
                systemctl --user set-environment GTK_THEME="${cfg.gtk.name}" XCURSOR_THEME="${cfg.cursor.name}" XCURSOR_SIZE="${toString cfg.cursor.size}" 2>/dev/null || true
              fi
            fi
          ''
        );

        # Symlinks para apps que não leem o perfil do Home Manager (Flatpak, Qt, WMs puros)
        file =
          linkTheme ".themes" "themes" cfg.gtk
          // linkTheme ".local/share/themes" "themes" cfg.gtk
          // linkTheme ".icons" "icons" cfg.icons
          // linkTheme ".local/share/icons" "icons" cfg.icons
          // linkTheme ".icons" "icons" cfg.cursor
          // linkTheme ".local/share/icons" "icons" cfg.cursor
          // lib.optionalAttrs (cfg.icons.package == pkgs.papirus-icon-theme) {
            ".icons/Papirus".source = mkDefault "${pkgs.papirus-icon-theme}/share/icons/Papirus";
            ".local/share/icons/Papirus".source = mkDefault "${pkgs.papirus-icon-theme}/share/icons/Papirus";
          }
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
