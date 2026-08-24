{ pkgs, ... }:
{
  users.users = {
    juca = {
      description = "Juca's user configuration";
      initialPassword = "pass";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrd5yF/0aMECHqkM1oNrOX5QBQ4sYbkiNR15XzBGkUU Reinaldo P Jr" ];
      homeMode = "0755";
      packages = with pkgs; [ home-manager duf ];
      shell = pkgs.bash;
    };
  };
}
