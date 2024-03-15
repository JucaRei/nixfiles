{ config, desktop, hostname, inputs, lib, pkgs, platform, username, ... }:
let
  isWorkstation = if (desktop != null) then true else false;
  isServer = if (hostname == "DietPi") then true else false;
in
{
  # sha512crypt
  users = {
    enforceIdUniqueness = true;
    users = {
      juca = {
        hashedPassword = "$6$v5.BOLgHd36TdTbu$NN1asLX6q8Kq8xCMp.0MtMKpaS7mHazfjRyE7V6vCTBmaO/e5t3lnrEp0ispI70xU3x6uCw0ataw0GX0DJcym1";
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
