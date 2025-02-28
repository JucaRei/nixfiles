{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.console.neofetch;
in
{
  options.console.neofetch = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ neofetch ];
      file = {
        # "${config.xdg.configHome}/neofetch/config.conf".text = builtins.readFile ../../../../resources/dots/neofetch/config.conf;
        "${config.xdg.configHome}/neofetch/config.conf".text =
          builtins.readFile ../../../dots/neofetch/electric.conf;
      };
    };
  };
}
