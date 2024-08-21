{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.zoxide;
in
{
  options.modules.zoxide = {
    enable = mkOption {
      default = true;
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
        "--cmd cd"
        "--hook pwd"
      ];
    };
  };
}
