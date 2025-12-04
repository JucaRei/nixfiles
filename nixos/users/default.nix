{ config, lib, pkgs, username, ... }:
let
  inherit (lib) mkIf mkForce optional;
  hasGroup = group: builtins.hasAttr group config.users.groups;
  filterExistingGroups = builtins.filter hasGroup;
in
{

  imports = [ ./root ]
    ++ optional (builtins.pathExists ./${username}) ./${username};

  config = mkIf (username != null) {
    users.users.${username} = {
      shell = pkgs.bash;
      extraGroups = [
        "input"
        "users"
        "wheel"
      ] ++ filterExistingGroups [
        "adm"
        "networkmanager"
      ];
      homeMode = mkForce "0755";
      isNormalUser = mkForce true;
    };
  };
}
