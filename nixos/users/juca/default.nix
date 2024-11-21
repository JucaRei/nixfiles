{ username, ... }:
{
  users.users.juca = {
    description = "Reinaldo P Jr";
    # mkpasswd -m sha-512
    hashedPassword = "$6$nOWm53r88anKugNB$71oxJWP8dU6oLrUX8TlTDINUUMy4G.tb07aH7MPD6NUmmVkI6slCoIDcFY/Dfe/Sy.pAVyUF8aq2/ko/Ml7Ml.";
  };
  systemd.tmpfiles.rules = [ "d /mnt/snapshot/${username} 0755 ${username} users" ];
}
