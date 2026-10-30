{
  pkgs,
  lib,
  nixGLWrapper ? lib.id,
  ...
}:
let
  fhd = {
    width = 1920;
    height = 1080;
    refresh = 60;
  };
in
{
  config = {
    desktop = {
      monitors = [
        (
          fhd
          // {
            name = "Virtual-1";
            x = 0;
            y = 0;
            primary = true;
          }
        )
      ];

      bspwm.extraKeybindings = {
        "ctrl + shift + t" = "bspc node -t '~floating'";
      };
    };

    home = {
      packages = [
        (nixGLWrapper pkgs.mdhero)
        pkgs.rustdesk
      ];

      sessionPath = [
        "/usr/sbin"
        "/sbin"
      ];

      sessionVariables = {
        NIX_REMOTE = "daemon";
        LC_ALL = "";
      };
    };

    services.polybar.config."module/keyboard" = {
      layout-icon-0 = "us;INTL";
      layout-icon-1 = "br;ABNT2";
      label-layout = "%icon%";
    };

    system.services.flatpak.enable = true;
  };
}
