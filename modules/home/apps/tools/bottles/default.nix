{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.tools.bottles;
in
{
  options.${namespace}.apps.tools.bottles = with types; {
    enable = mkBoolOpt false "Whether or not to enable Bottles.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ bottles ];
  };
}
