{ hostname, isWorkstation, lib, config, ... }:
let
  inherit (lib) mkForce;
in
{
  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = if (config.core.boot.isDualBoot == true) then true else false;
  };
  services = {
    geoclue2 = mkForce {
      enable = isWorkstation;
    };
  };
}
