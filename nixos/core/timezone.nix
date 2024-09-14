{ hostname, isWorkstation, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = isWorkstation && hostname == "nitro"; ### Dual boot
  };
  services = {
    geoclue2 = mkForce {
      enable = isWorkstation;
    };
  };
}
