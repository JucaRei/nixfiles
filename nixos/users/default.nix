{ config, lib, pkgs, username, ... }:
let
  inherit (lib) optionals mkDefault
    # optional
    ;
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  # groupName = "${username}";
in
{
  imports = [ ./root ] ++
    # optional (builtins.pathExists (./. + "/${username}")) ./${username} ++ # return the single user config if it exists
    optionals (builtins.pathExists (./. + "/${username}")) [ ./${username} ]; # multiple user configs

  config = {

    users.users = {
      ${username} = {
        isNormalUser = true;
        extraGroups = [
          "input"
          "users"
          "wheel"
        ]
        ++ ifExists [
          "adm"
          "networkmanager"
          # "audio"
          # "docker"
        ];
        packages = with pkgs; [ git htop ];

        # groups.${groupName}.gid = mkDefault config.users.users.${username}.uid; # make uid/gid == 1000
        # extraUsers.${username} = {
        #   name = "${username}";
        #   group = "${username}";
        # };
      };

      isNormalUser = true; # This is the default, but just to be explicit
      shell = mkDefault pkgs.bash;
    };

    environment.localBinInPath = true;
  };
}
