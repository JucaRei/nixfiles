{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.tools.gparted;
in
{
  options.${namespace}.apps.tools.gparted = with types; {
    enable = mkBoolOpt false "Whether or not to enable gparted.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gparted ];
  };
}
