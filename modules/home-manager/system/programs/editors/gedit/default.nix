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
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    home.sessionVariables = mkIf cfg.default {
      EDITOR = mkDefault "gedit";
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
