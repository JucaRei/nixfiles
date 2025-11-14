{ config, lib, desktop, isWorkstation, ... }:
let
  inherit (lib) nullOr enum optional mkOption mkOptionDefault;
  cfg = config.desktop.environments;
in
{
  imports = [ ]
    ++
    optional (builtins.pathExists (./. + "/environments/${desktop}")) ./environments/${desktop}
  ;

  config = {
    hardware.cpu = {
      enable = mkOptionDefault true;
      improveTCP = mkOptionDefault true;
    };
  };
}
