{ lib, pkgs, username, config, ... }:
let
  inherit (lib) mkForce optional;
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports = [ ./root ]
    ++ lib.optional builtins.pathExists (./. + "/${username}") ./${username};

  environment.localBinInPath = true;
  users = {
    users.${username} = {
      extraGroups = [
        "input"
        "users"
        "wheel"
      ]
      ++ ifExists [
        #   "kvm"
        "adm"
      ]
      ;
      homeMode = "0755";
      isNormalUser = mkForce true;
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrd5yF/0aMECHqkM1oNrOX5QBQ4sYbkiNR15XzBGkUU Reinaldo P Jr" ];
      packages = [ pkgs.home-manager ];
      shell = pkgs.fish;
    };
  };
}
