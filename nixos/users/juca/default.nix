{ username, ... }:
{
  users.users.juca = {
    description = "Reinaldo P Jr";
    # mkpasswd -m sha-512
    hashedPassword = "$6$Xtum91YtXaphROBA$/T1AlLDH/lTSUz1l/TgwnOSrfoU6LVcWhReAqFyZtOD0wzUTNoBITD7F5o71gVsRVRLlSh/TT8i0VOYAChNOX.";
  };
  systemd.tmpfiles.rules = [ "d /mnt/snapshot/${username} 0755 ${username} users" ];
}
