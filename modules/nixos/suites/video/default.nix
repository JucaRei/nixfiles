{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.video;
in
{
  options.${namespace}.suites.video = with types; {
    enable = mkBoolOpt false "Whether or not to enable video configuration.";
  };

  config = mkIf cfg.enable {
    excalibur = {
      apps = {
        pitivi = enabled;
        obs = enabled;
      };
    };
  };
}
