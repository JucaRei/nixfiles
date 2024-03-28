{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.programs.google-chrome;
in
{
  options.programs.google-chrome = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      google-chrome
    ];
  };
}
