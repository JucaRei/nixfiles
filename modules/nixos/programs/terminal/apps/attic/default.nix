{ config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.apps.attic;
in
{
  options.${namespace}.programs.terminal.apps.attic = {
    enable = mkEnableOption "Attic";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ attic ]; };
}
