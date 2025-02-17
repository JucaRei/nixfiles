{ lib, pkgs, config, namespace, ... }:
let
  cfg = config.${namespace}.programs.graphical.games.steamtinkerlaunch;

  inherit (lib) mkIf mkEnableOption;
in
{
  options.${namespace}.programs.graphical.games.steamtinkerlaunch = {
    enable = mkEnableOption "Steam Tinker Launch";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ steamtinkerlaunch ]; };
}
