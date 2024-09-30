{ hostname, isWorkstation, lib, config, ... }:
let
  inherit (lib) mkDefault;
in
{
  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = if (config.core.boot.isDualBoot == true) then true else false;
  };
  services = {
    geoclue2 = mkDefault {
      enable = isWorkstation;
    };
  };
}
