{ config, username, hostname, isWorkstation, lib, ... }:
let
  variables = import ../hosts/${hostname}/variables.nix { inherit config username; }; # vars for better check
in
{
  time = {
    timeZone = "${variables.timezone}";
    hardwareClockInLocalTime = isWorkstation && hostname == "nitro"; ### Dual boot
  };

  services = {
    geoclue2 = lib.mkForce {
      enable = isWorkstation;
    };
  };
}
