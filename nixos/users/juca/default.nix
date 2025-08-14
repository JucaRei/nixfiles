{ config, pkgs, username, lib, osConfig, ... }:
let
  inherit (lib) mkIf;

in
{
  users.users = {
    juca = {
      description = "Juca's user configuration";
      # mkpasswd -m sha-512
      hashedPassword = "$6$nOWm53r88anKugNB$71oxJWP8dU6oLrUX8TlTDINUUMy4G.tb07aH7MPD6NUmmVkI6slCoIDcFY/Dfe/Sy.pAVyUF8aq2/ko/Ml7Ml.";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrd5yF/0aMECHqkM1oNrOX5QBQ4sYbkiNR15XzBGkUU Reinaldo P Jr" ];
      homeMode = "0755";
      packages = with pkgs; [ home-manager duf ];
      shell = pkgs.zsh;
    };
  };
}
