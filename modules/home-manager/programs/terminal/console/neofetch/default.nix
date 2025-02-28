{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.console.neofetch;
in
{
  options.programs.terminal.console.neofetch = {
    enable = mkOption {
      default = false;
      type = bool;
      description = "Enable neofetch";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ neofetch ];
      file = {
        # "${config.xdg.configHome}/neofetch/config.conf".text = builtins.readFile ../../../../resources/dots/neofetch/config.conf;
        "${config.xdg.configHome}/neofetch/config.conf".text =
          builtins.readFile ./conf/electric.conf;
      };
    };
  };
}
