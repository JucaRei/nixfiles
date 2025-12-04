{ pkgs, ... }:
let
  username = "juca";
in
{
  users.users.${username} = {
    home = "/home/${username}";
    group = "${username}";
    isNormalUser = true;
    description = "Juca's";
    hashedPassword = "$6$nOWm53r88anKugNB$71oxJWP8dU6oLrUX8TlTDINUUMy4G.tb07aH7MPD6NUmmVkI6slCoIDcFY/Dfe/Sy.pAVyUF8aq2/ko/Ml7Ml.";
    packages = with pkgs; [ htop ];
  };
  users.groups.${username} = {};
  systemd.tmpfiles.rules = [ "d /mnt/snapshot/${username} 0755 ${username} users" ];
}
