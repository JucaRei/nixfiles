{ options, config, pkgs, lib, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.security.superuser;
in
{

  config = mkIf cfg.manager == "doas" {
    # Disable sudo
    security.sudo.enable = false;

    # Enable and configure `doas`.
    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [ config.${namespace}.user.name ];
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
