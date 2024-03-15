{ config, desktop, hostname, inputs, lib, pkgs, platform, username, ... }:
let
  isWorkstation = if (desktop != null) then true else false;
  isServer = if (hostname == "DietPi") then true else false;
in
{
  users = {
    enforceIdUniqueness = true;
    users = {
      juca = {
        createHome = true;
        description = "Reinaldo P Jr";
        extraGroups = [ "whell" ];
        uid = 1000;
        linger = true;
        autoSubUidGidRange = true;
        shell = pkgs.fish;
      };
    };
    mutableUsers = false;
  };
}
