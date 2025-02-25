{ options, config, pkgs, lib, username, ... }:
let
  inherit (lib) mkIf;
  cfg = config.system.security.superuser;
in
{

  config = mkIf (cfg.manager == "doas") {
    # Disable sudo
    security.sudo.enable = false;

    # Enable and configure `doas`.
    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [ config.users.users.${username} ];
          noPass = true;
          keepEnv = true;
        }
      ];
    };

    # Add an alias to the shell for backward-compat and convenience.
    environment.shellAliases = {
      sudo = "doas";
    };
  };
}
