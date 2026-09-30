{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.programs.editors.zitext;
  inherit (lib)
    mkEnableOption
    mkIf
    mkDefault
    mkOption
    types
    ;
in
{
  options.system.programs.editors.zitext = {
    enable = mkEnableOption "ZITEXT text editor";

    default = mkOption {
      type = types.bool;
      default = false;
      description = "Define o ZITEXT como editor padrão de texto plano (text/plain).";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.zitext;
      description = "Pacote do ZITEXT a ser utilizado.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    # home.sessionVariables = mkIf cfg.default {
    #   EDITOR = mkDefault "zitext";
    # };

    xdg.mimeApps = mkIf cfg.default {
      defaultApplications = {
        "text/plain" = mkDefault "zitext.desktop";
      };
      associations.added = {
        "text/plain" = "zitext.desktop";
      };
    };
  };
}
