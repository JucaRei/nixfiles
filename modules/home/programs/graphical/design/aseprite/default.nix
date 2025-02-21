{ lib, config, pkgs, namespace, ... }:
let
  cfg = config.${namespace}.programs.graphical.design.aseprite;
in
{
  options.${namespace}.programs.graphical.design.art.aseprite = {
    enable = lib.mkEnableOption "aseprite";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      aseprite
    ];
  };
}
