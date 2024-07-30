{ config, username, ... }:
{
  # sha512crypt
  users.users.juca = {
    description = "Reinaldo P Jr";
    hashedPassword = "$y$j9T$dTw1jxn2A9K1CzXjFMU.T/$8oEdG9SIg/Y0FrSXlOdmDfH3KZMEZvQaExeI4G70GGC";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/snapshot/${username} 0755 ${username} users"
  ];
}
