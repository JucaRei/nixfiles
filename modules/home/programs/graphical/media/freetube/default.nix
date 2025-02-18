{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.media.freetube;
in
{
  options.${namespace}.programs.graphical.media.freetube = with types; {
    enable = mkBoolOpt false "Whether or not to enable FreeTube.";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ freetube ]; };
}
