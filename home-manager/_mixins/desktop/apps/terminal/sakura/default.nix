{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.terminal.sakura;
in
{
  options = {
    desktop.apps.terminal.sakura = {
      enable = mkEnableOption "Enables sakura terminal.";
    };
  };
  config = mkIf cfg.enable {
    home = {
      file = {
        "${config.xdg.configHome}/sakura/sakura.conf".text =
          builtins.readFile ./sakura.conf;
      };
      packages = with pkgs; [ sakura ];
    };
  };
}
