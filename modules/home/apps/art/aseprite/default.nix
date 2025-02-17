{ lib, config, pkgs, ... }:
let
  cfg = config.excalibur.apps.aseprite;
in
{
  options.excalibur.apps.art.aseprite = {
    enable = lib.mkEnableOption "aseprite";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      aseprite
    ];
  };
}
