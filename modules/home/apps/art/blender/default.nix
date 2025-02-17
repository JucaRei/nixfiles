{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.blender;
in
{
  options.${namespace}.apps.art.blender = with types; {
    enable = mkBoolOpt false "Whether or not to enable Blender.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ blender ];
  };
}
