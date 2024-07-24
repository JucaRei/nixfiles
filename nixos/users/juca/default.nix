{ config, username, ... }:
{
  # sha512crypt
  users.users.juca = {
    description = "Reinaldo P Jr";
    hashedPassword = "$6$A5gukqBVeM3eJblr$K6L1kxSDvJJjy6.LVx78d1QojtmGJBwpI3MPvc52h8H/Avg0KQW/uG6QazLiuoC2vGZ79nq3czvj96hEdSLUf1";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/snapshot/${username} 0755 ${username} users"
  ];
}
