{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.powerline-go;
in
{
  options.services.powerline-go = {
    enable = mkOption {
      default = false;
      type = types.bool;
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
