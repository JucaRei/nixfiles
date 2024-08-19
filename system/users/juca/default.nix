{ username, ... }:
{
  users.users.juca = {
    description = "Reinaldo P Jr";
    # mkpasswd -m sha-512
    hashedPassword = "$6$vtPLMKG2K9PTiyDb$3t01hR6bJAlnJVAPj3oqjl3k.vJHsRSH4VAO7q/QZoOCegH72xAY.iAVoZtPkcr2Mr3mfAFfajY6LWJ6lA95A/";
  };
  systemd.tmpfiles.rules = [ "d /mnt/.snapshot/${username} 0755 ${username} users" ];
}
