{ config, username, lib, osConfig, ... }:
let
  inherit (lib) mkIf;
  container_enabled = (osConfig.system.services.ct-podman.enable) || (config.system.services.container.enable);
in
{
  users.users.${username} = {
    description = "Reinaldo P Jr";
    # mkpasswd -m sha-512
    hashedPassword = "$6$nOWm53r88anKugNB$71oxJWP8dU6oLrUX8TlTDINUUMy4G.tb07aH7MPD6NUmmVkI6slCoIDcFY/Dfe/Sy.pAVyUF8aq2/ko/Ml7Ml.";

    # Subordinate user ids that user is allowed to use. They are set into
    # /etc/subuid and are used by newuidmap for user namespaces. (Needed for
    # LXC.)
    subGidRanges = mkIf container_enabled [{
      startUid = 1000000;
      count = 65536;
    }];
    subUidRanges = mkIf container_enabled [{
      startGid = 1000000;
      count = 65536;
    }];
  };
  systemd.tmpfiles.rules = [ "d /mnt/snapshot/${username} 0755 ${username} users" ];
}
