{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.shell.zsh;
in
{
  options = {
    programs.terminal.shell.zsh = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's zsh with configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
      };
    };
  };
}
