{ config, lib, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.time;
  boot = config.${namespace}.system.boot;
in
{
  options.${namespace}.system.time = with types; {
    enable = mkBoolOpt false "Whether or not to configure timezone information.";
  };

  config = mkIf cfg.enable {
    time = {
      timeZone = "America/Sao_Paulo";
      hardwareClockInLocalTime = if (boot.isDualBoot == true) then true else false;
    };
  };
}
