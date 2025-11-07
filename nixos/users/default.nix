{ config, lib, pkgs, username, ... }:
let
  inherit (lib) optionals mkDefault;
  hasGroup = group: builtins.hasAttr group config.users.groups;
  filterExistingGroups = builtins.filter hasGroup;
in
{
  imports = [ ./root ]
    ++ optionals (builtins.pathExists ./${username}) [ ./${username} ]; # multiple user configs
  # optional (builtins.pathExists (./. + "/${username}")) ./${username} ++ # return the single user config if it exists

  config = {
    users.users.${username} = {
      isNormalUser = true;
      shell = mkDefault pkgs.bash;
      extraGroups = [
        "input"
        "users"
        "wheel"
      ] ++ filterExistingGroups [
        "adm"
        "networkmanager"
        # "audio"
        # "docker"
      ];
      packages = with pkgs; [ git htop ];
    };

    environment.localBinInPath = true;
  };
}
