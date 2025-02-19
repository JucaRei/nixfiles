{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.archetypes.gaming;
in
{
  options.${namespace}.archetypes.gaming = with types; {
    enable = mkBoolOpt false "Whether or not to enable the gaming archetype.";
  };

  config = mkIf cfg.enable {
    excalibur.suites = {
      common = enabled;
      desktop-environment = enabled;
      games = enabled;
      social = enabled;
      media = enabled;
    };
  };
}
