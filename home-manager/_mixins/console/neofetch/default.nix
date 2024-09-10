{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.custom.console.neofetch;
in
{
  options.custom.console.neofetch = {
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
          builtins.readFile ../../config/neofetch/electric.conf;
      };
    };
  };
}
