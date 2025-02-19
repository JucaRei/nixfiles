{ lib, config, pkgs, ... }:
let
  cfg = config.excalibur.programs.graphical.design.aseprite;
in
{
  options.excalibur.programs.graphical.design.art.aseprite = {
    enable = lib.mkEnableOption "aseprite";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      aseprite
    ];
  };
}
