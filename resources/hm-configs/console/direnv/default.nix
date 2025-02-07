{ lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.direnv;
in
{
  options.direnv = {
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
          direnvrcExtra = ''
            echo "loaded direnv!"
          '';
        };
      };
      git.ignores = [ ".direnv" ];
    };
  };
}
