{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.emulation;
in
{
  options.${namespace}.suites.emulation = with types; {
    enable = mkBoolOpt false "Whether or not to enable emulation configuration.";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      programs = {
        graphical = {
          games = {
            yuzu = enabled;
            pcsx2 = enabled;
            dolphin = enabled;
          };
        };
      };
    };
  };
}
