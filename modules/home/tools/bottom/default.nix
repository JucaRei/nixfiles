{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.tools.bottom;
in
{
  options.${namespace}.tools.bottom = with types; {
    enable = mkBoolOpt false "Whether or not to enable Bottom.";
  };

  config = mkIf cfg.enable {
    excalibur.home.extraOptions = {
      home.packages = with pkgs; [ bottom ];
    };
  };
}
