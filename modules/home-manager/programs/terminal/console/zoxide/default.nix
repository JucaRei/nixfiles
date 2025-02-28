{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.console.zoxide;
in
{
  options.programs.terminal.console.zoxide = {
    enable = mkOption {
      default = false;
      type = bool;
      description = "Enable's zoxide";
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
