{ lib, config, ... }:
with lib;
let
  cfg = config.modules.dircolors;
in
{
  options.modules.dircolors = {
    enable = mkOption {
      default = true;
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
