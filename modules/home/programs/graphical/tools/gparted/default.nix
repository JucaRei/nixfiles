{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.tools.gparted;
in
{
  options.${namespace}.programs.graphical.tools.gparted = {
    enable = mkBoolOpt false "Whether or not to enable gparted.";
  };

  config = mkIf cfg.enable {
    ${namespace}.home.extraOptions = {
      home.packages = with pkgs; [ gparted ];
    };
  };
}
