{
  config,
  lib,
  pkgs,
  cfg,
  palette,
  paletteName,
  colors,
  isDark,
  linkTheme,
}:
let
  inherit (lib) mkIf mkDefault;
in
mkIf (cfg.enable && cfg.targets.gtk) {
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

  # Style Scheme dinâmico para GtkSourceView (gedit, meld, gnome-text-editor)
  xdg.dataFile = mkIf (cfg.targets.gedit or true) (
    let
      schemeId = builtins.replaceStrings [ "-" " " ] [ "_" "_" ] (lib.strings.toLower paletteName);
      schemeXml = import ./gtksourceview.nix {
        id = schemeId;
        name = paletteName;
        inherit (palette) variant;
        inherit colors;
      };
      styleDirs = [
        "gedit/styles"
        "libgedit-gtksourceview-300/styles"
        "gtksourceview-5/styles"
        "gtksourceview-4/styles"
        "gtksourceview-3.0/styles"
        "gtksourceview-2.0/styles"
      ];
    in
    lib.listToAttrs (
      map (dir: {
        name = "${dir}/${schemeId}.xml";
        value = {
          text = schemeXml;
        };
      }) styleDirs
    )
  );

  # Configuração declarativa para xsettingsd (gerenciador XSETTINGS leve para X11/BSPWM/DWM)
  xdg.configFile = mkIf (cfg.xsettingsd.enable && cfg.targets.xsettingsd) {
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
  systemd.user.services.xsettingsd = mkIf (cfg.xsettingsd.enable && cfg.targets.xsettingsd) {
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
    packages = mkIf (cfg.xsettingsd.enable && cfg.targets.xsettingsd) [ pkgs.xsettingsd ];

    sessionVariables = {
      GTK_THEME = mkDefault cfg.gtk.name;
      XCURSOR_THEME = mkDefault cfg.cursor.name;
      XCURSOR_SIZE = mkDefault (toString cfg.cursor.size);
    };

    # Recarrega o xsettingsd e sincroniza variáveis de sessão na sessão gráfica atual
    activation.reloadXsettings = mkIf (cfg.xsettingsd.enable && cfg.targets.xsettingsd) (
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
}
