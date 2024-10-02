{ username, pkgs, config, lib, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.core.su;
in
{
  options.core.su = {
    enable = mkOption {
      default = true;
      type = with types; bool;
      description = "Enables the default super user security privileges tool.";
    };
    super = mkOption {
      type = types.enum [ "sudo" "doas" ];
      default = "sudo";
      description = "Select the default super user security privileges tool.";
    };
  };

  config = {
    security = {
      sudo.enable = false; # Disable sudo

      doas = {
        enable = true;
        # extraConfig = ''
        # permit nopass :wheel
        # '';
        extraRules = [
          {
            users = [ "${username}" ];
            noPass = true;
            keepEnv = true;
            # persist = true;
          }
        ];
        #wheelNeedsPassword = false;
      };
    };
    environment.systemPackages = [ (pkgs.writeScriptBin "sudo" ''exec doas "$@"'') ];
  };
}
