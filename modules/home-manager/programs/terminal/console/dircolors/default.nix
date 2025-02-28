{ lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.programs.terminal.console.dircolors;
in
{
  options.programs.terminal.console.dircolors = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    programs.dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
