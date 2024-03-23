{ config, pkgs, username, ... }: {

  services.duplicati = {
    enable = true;
    package = pkgs.duplicati;
    dataDir = "/home/${username}/.duplicati-backups/";
    user = "${username}";
    port = 8200;
    interface = "127.0.0.1";
  };

}
