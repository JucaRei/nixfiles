{ lib, config, pkgs, ... }:
let
  cfg = config.excalibur.apps.aseprite;
in
{
  options.excalibur.apps.aseprite = {
    enable = lib.mkEnableOption "aseprite";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      aseprite
    ];
  };
}
