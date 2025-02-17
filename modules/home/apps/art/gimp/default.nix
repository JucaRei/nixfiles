{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.art.gimp;
in
{
  options.${namespace}.apps.art.gimp = with types; {
    enable = mkBoolOpt false "Whether or not to enable Gimp.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gimp ];
  };
}
