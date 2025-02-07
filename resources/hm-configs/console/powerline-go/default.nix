{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.console.powerline-go;
in
{
  options.console.powerline-go = {
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
