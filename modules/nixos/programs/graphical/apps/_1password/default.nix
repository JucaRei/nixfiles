{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.programs.graphical.apps._1password;
in
{
  options = {
    programs.graphical.apps._1password = {
      enable = mkEnableOption "Install password app.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      _1password-cli
      _1password-gui
    ];
  };
}
