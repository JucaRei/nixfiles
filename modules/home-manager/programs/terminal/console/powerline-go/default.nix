{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.console.powerline-go;
in
{
  options.programs.terminal.console.powerline-go = {
    enable = mkOption {
      default = false;
      type = bool;
      description = "Enable's powerline-go.";
    };
  };

  config = mkIf cfg.enable {
    programs.powerline-go = {
      enable = true;
      settings = {
        cwd-max-depth = 5;
        cwd-max-dir-size = 12;
        max-width = 60;
      };
    };
  };
}
