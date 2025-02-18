{ config, lib, pkgs, namespace, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.programs.graphical.tools.partitionmanager;
in
{
  options.${namespace}.programs.graphical.tools.partitionmanager = {
    enable = mkBoolOpt false "Whether or not to enable partitionmanager.";
  };

  config = mkIf cfg.enable {
    programs.partition-manager = {
      enable = true;
      package = pkgs.kdePackages.partitionmanager;
    };
  };
}
