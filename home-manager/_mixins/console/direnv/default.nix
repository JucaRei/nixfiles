{ lib, config, ... }:
with lib;
let
  cfg = config.services.direnv;
in
{
  options.services.direnv = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        # enableFishIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
        nix-direnv = {
          enable = true;
        };
        config = {
          whitelist = {
            prefix = [
              "${config.home.homeDirectory}/code"
            ];
          };
        };
      };
      git.ignores = [ ".direnv" ];
    };
  };
}
