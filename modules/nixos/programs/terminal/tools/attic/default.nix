{ config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.tools.attic;
in
{
  options.${namespace}.programs.terminal.tools.attic = {
    enable = mkEnableOption "Attic";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ attic ]; };
}
