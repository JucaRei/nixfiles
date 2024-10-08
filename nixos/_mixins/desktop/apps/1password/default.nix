{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps._1password;
in
{
  options = {
    desktop.apps._1password = {
      enable = mkEnableOption "Install password app.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      _1password
      _1password-gui
    ];
  };
}
