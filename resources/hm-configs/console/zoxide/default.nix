{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.console.zoxide;
in
{
  options.console.zoxide = {
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
        "--cmd cd"
        "--hook pwd"
      ];
    };
  };
}
