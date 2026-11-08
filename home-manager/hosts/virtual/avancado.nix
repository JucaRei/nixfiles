# Advanced host-specific configurations for virtual
_: {
  config = {
    desktop.bspwm.extraKeybindings = {
      "ctrl + shift + t" = "bspc node -t '~floating'";
    };

    home = {
      sessionPath = [
        "/usr/sbin"
        "/sbin"
      ];

      sessionVariables = {
        NIX_REMOTE = "daemon";
        LC_ALL = "";
        TMPDIR = "/var/tmp";
      };
    };

    services.polybar.config."module/keyboard" = {
      layout-icon-0 = "us;INTL";
      layout-icon-1 = "br;ABNT2";
      label-layout = "%icon%";
    };
  };
}
