{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.powerline-go;
in
{
  options.modules.powerline-go = {
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
        theme = "gruvbox";
        max-width = 60;
      };
    };
  };
}
