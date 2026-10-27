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
    mkOption
    types
    ;

  isDark = (config.desktop.theme.variant or "dark") == "dark";
  themeName =
    if config.desktop.theme ? gtk && config.desktop.theme.gtk ? name then
      config.desktop.theme.gtk.name
    else if config.gtk ? theme && config.gtk.theme ? name then
      config.gtk.theme.name
    else
      "";
  themePackage =
    if config.desktop.theme ? gtk && config.desktop.theme.gtk ? package then
      config.desktop.theme.gtk.package
    else if config.gtk ? theme && config.gtk.theme ? package then
      config.gtk.theme.package
    else
      null;
  iconPackage =
    if config.desktop.theme ? icons && config.desktop.theme.icons ? package then
      config.desktop.theme.icons.package
    else if config.gtk ? iconTheme && config.gtk.iconTheme ? package then
      config.gtk.iconTheme.package
    else
      null;

  themeDataDir = lib.optionalString (themePackage != null) "${themePackage}/share:";
  iconDataDir = lib.optionalString (iconPackage != null) "${iconPackage}/share:";

  # Esquema de sintaxe padrão sincronizado com a paleta declarativa
  defaultTheme =
    if config.desktop.theme ? name then
      (
        if config.desktop.theme.name == "catppuccin-macchiato" then
          "catppuccin_macchiato"
        else if config.desktop.theme.name == "catppuccin-mocha" then
          "catppuccin_mocha"
        else if config.desktop.theme.name == "dracula" then
          "dracula"
        else
          "catppuccin_macchiato"
      )
    else
      "catppuccin_macchiato";

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

  styleDirs = [
    "gedit/styles"
    "libgedit-gtksourceview-300/styles"
    "gtksourceview-5/styles"
    "gtksourceview-4/styles"
    "gtksourceview-3.0/styles"
    "gtksourceview-2.0/styles"
  ];
  styleFiles = {
    "catppuccin-macchiato.xml" = ./catppuccin-macchiato.xml;
    "catppuccin-mocha.xml" = ./catppuccin-mocha.xml;
    "dracula.xml" = ./dracula.xml;
  };
  styleDataFiles = lib.listToAttrs (
    lib.concatMap (
      dir:
      lib.mapAttrsToList (name: source: {
        name = "${dir}/${name}";
        value = { inherit source; };
      }) styleFiles
    ) styleDirs
  );
in
{
  options.system.programs.editors.gedit = {
    enable = mkEnableOption "GNOME Text Editor (gedit)";

    default = mkOption {
      type = types.bool;
      default = true;
      description = "Define o gedit como editor padrão de texto plano (text/plain).";
    };

    package = mkOption {
      type = types.package;
      default = gedit-wrapped;
      description = "Pacote do gedit a ser utilizado.";
    };

    theme = mkOption {
      type = types.str;
      default = defaultTheme;
      description = "Tema / esquema de cores padrão do gedit.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    home.sessionVariables = mkIf cfg.default {
      EDITOR = mkDefault "gedit";
    };

    xdg.dataFile = styleDataFiles;

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
