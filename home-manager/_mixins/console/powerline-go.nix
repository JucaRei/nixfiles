{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.powerline-go;
in
{
  options = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = {
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
