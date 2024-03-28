{ lib, config, ... }:
with lib;
let
  cfg = config.services.dircolors;
in
{
  options.services.dircolors = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = {
    programs.dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
