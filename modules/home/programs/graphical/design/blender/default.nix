{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.design.der;
in
{
  options.${namespace}.programs.graphical.design.blender = with types; {
    enable = mkBoolOpt false "Whether or not to enable Blender.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ blender ];
  };
}
