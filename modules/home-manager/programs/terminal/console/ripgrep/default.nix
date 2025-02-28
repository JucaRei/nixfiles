{ lib, config, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.console.ripgrep;
in
{
  options.programs.terminal.console.ripgrep = {
    enable = mkOption {
      default = false;
      type = bool;
      description = "Enable's ripgrep";
    };
  };
  config = mkIf cfg.enable {
    programs = {
      ripgrep = {
        arguments = [
          "--colors=line:style:bold"
          "--max-columns-preview"
          "--smart-case"
        ];
        enable = true;
      };
    };
  };
}
