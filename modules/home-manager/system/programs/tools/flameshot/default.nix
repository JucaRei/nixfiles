{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.tools.flameshot;
in
{
  options = {
    system.programs.tools.flameshot = {
      enable = mkEnableOption "Enable Flameshot screenshot tool.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.flameshot ];

    services.flameshot = {
      enable = true;
      package = pkgs.flameshot;
      settings = {
        General = {
          disabledTrayIcon = false;
          showStartupLaunchMessage = false;
          savePath = "${config.home.homeDirectory}/Pictures";
        };
      };
    };
  };
}
