{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  ...
}:
let
  cfg = config.system.programs.editors.gedit;
  inherit (lib)
    mkEnableOption
    mkIf
    mkDefault
    ;

  isDark = (config.desktop.theme.variant or "dark") == "dark";
  themeName = config.desktop.theme.gtk.name;
  themePackage = config.desktop.theme.gtk.package;
  iconPackage = config.desktop.theme.icons.package;

  themeDataDir = lib.optionalString (themePackage != null) "${themePackage}/share:";
  iconDataDir = lib.optionalString (iconPackage != null) "${iconPackage}/share:";

  # Esquema de sintaxe padrão derivado da paleta declarativa
  defaultTheme = builtins.replaceStrings [ "-" ] [ "_" ] config.desktop.theme.name;

  gedit-base = nixGLWrapper pkgs.gedit;

  gedit-wrapped = pkgs.symlinkJoin {
    name = "gedit-wrapped";
    paths = [ gedit-base ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -rf $out/bin
      mkdir -p $out/bin

      for bin in ${gedit-base}/bin/*; do
        if [ -x "$bin" ]; then
          makeWrapper "$bin" "$out/bin/$(basename "$bin")" \
            --prefix XDG_DATA_DIRS : "$out/share:${pkgs.gedit}/share:${themeDataDir}${iconDataDir}${config.home.homeDirectory}/.local/share:${config.home.homeDirectory}/.nix-profile/share:/usr/local/share:/usr/share" \
            --set-default GTK_APPLICATION_PREFER_DARK_THEME "${if isDark then "1" else "0"}" \
            --run '
              _clean_theme="''${GTK_THEME%%:*}"
              if [ -z "$_clean_theme" ] || [ ! -d "$HOME/.themes/$_clean_theme" -a ! -d "$HOME/.local/share/themes/$_clean_theme" -a ! -d "/usr/share/themes/$_clean_theme" ]; then
                export GTK_THEME="${themeName}${if isDark then ":dark" else ""}"
              fi
            '
        fi
      done
    '';
  };
in
{
  options.system.programs.editors.gedit = {
    enable = mkEnableOption "GNOME Text Editor (gedit)";

    default = lib.my.mkBool true "Define o gedit como editor padrão de texto plano (text/plain).";

    package = lib.my.mkPkg gedit-wrapped "Pacote do gedit a ser utilizado.";

    theme = lib.my.mkStr defaultTheme "Tema / esquema de cores padrão do gedit.";
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    home.sessionVariables = mkIf cfg.default {
      EDITOR = mkDefault "gedit";
    };

    dconf.settings = {
      "org/gnome/gedit/preferences/editor" = {
        scheme = cfg.theme;
        style-scheme = cfg.theme;
        style-scheme-for-dark-theme-variant = cfg.theme;
        style-scheme-for-light-theme-variant = cfg.theme;
        syntax-highlighting = true;
      };
      "org/gnome/gedit/preferences/ui" = {
        theme-variant = if isDark then "dark" else "light";
      };
      "org/gnome/TextEditor" = {
        style-scheme = cfg.theme;
        style-variant = if isDark then "dark" else "light";
      };
    };

    xdg.mimeApps = mkIf cfg.default {
      defaultApplications = {
        "text/plain" = mkDefault "org.gnome.gedit.desktop";
      };
      associations.added = {
        "text/plain" = "org.gnome.gedit.desktop";
      };
    };
  };
}
