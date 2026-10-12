{
  config,
  lib,
  pkgs,
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
      default = pkgs.gedit;
      description = "Pacote do gedit a ser utilizado.";
    };

    theme = mkOption {
      type = types.str;
      default = "dracula";
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

    xdg.dataFile = {
      "gedit/styles/dracula.xml".source = ./dracula.xml;
      "libgedit-gtksourceview-300/styles/dracula.xml".source = ./dracula.xml;
      "gtksourceview-5/styles/dracula.xml".source = ./dracula.xml;
      "gtksourceview-4/styles/dracula.xml".source = ./dracula.xml;
      "gtksourceview-3.0/styles/dracula.xml".source = ./dracula.xml;
      "gtksourceview-2.0/styles/dracula.xml".source = ./dracula.xml;
    };

    dconf.settings = {
      "org/gnome/gedit/preferences/editor" = {
        scheme = cfg.theme;
        style-scheme-for-dark-theme-variant = cfg.theme;
        style-scheme-for-light-theme-variant = cfg.theme;
      };
      "org/gnome/gedit/preferences/ui" = {
        theme-variant = "dark";
      };
      "org/gnome/TextEditor" = {
        style-scheme = cfg.theme;
        style-variant = "dark";
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
