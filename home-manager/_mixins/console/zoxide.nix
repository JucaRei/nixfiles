{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.zoxide;
in
{
  options.services.zoxide = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd" # Replace cd with z and add cdi to access zi
        "--hook pwd"
      ];
    };
  };
}
