{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.neofetch;
in
{
  options.services.neofetch = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ neofetch ];
      file = {
        # "${config.xdg.configHome}/neofetch/config.conf".text = builtins.readFile ../config/neofetch/config.conf;
        "${config.xdg.configHome}/neofetch/config.conf".text =
          builtins.readFile ../config/neofetch/electric.conf;
      };
    };
  };
}
