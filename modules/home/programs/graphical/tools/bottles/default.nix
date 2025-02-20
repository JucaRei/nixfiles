{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.tools.bottles;
in
{
  options.${namespace}.programs.graphical.tools.bottles = with types; {
    enable = mkBoolOpt false "Whether or not to enable Bottles.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ bottles ];
  };
}
