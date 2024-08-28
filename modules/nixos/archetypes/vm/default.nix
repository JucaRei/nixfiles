{ config
, lib
, namespace
, ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt enabled;

  cfg = config.${namespace}.archetypes.vm;
in
{
  options.${namespace}.archetypes.vm = {
    enable = mkBoolOpt false "Whether or not to enable the vm archetype.";
  };

  config = mkIf cfg.enable {

    excalibur = {

      nix = enabled;

      suites = {
        common = enabled;
        desktop = enabled;

        development = {
          enable = true;
          dockerEnable = true;
        };
      };
    };
  };
}
