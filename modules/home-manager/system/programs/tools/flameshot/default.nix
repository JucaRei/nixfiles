{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
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
    home.packages = [ (nixGLWrapper pkgs.flameshot) ];

    services.flameshot = {
      enable = true;
      package = nixGLWrapper pkgs.flameshot;
      settings = {
        General = {
          disabledTrayIcon = false;
          showStartupLaunchMessage = false;
          savePath = "${config.home.homeDirectory}/Pictures/Screenshots";
        };
      };
    };
  };
}
