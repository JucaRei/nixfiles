{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.bspwm-xs;
  inherit (lib) mkIf mkOption types;
in {
  options.modules.bspwm-xs = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Wheather enable bspwm xsession management by home-manager";
    };
  };

  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      windowManager.bspwm = {
        enable = true;
        alwaysResetDesktops = true;
      };
      numlock.enable = true;
      # If managed by home-manager
      scriptPath = ".hm-xsession";
      profilePath = ".hm-profile";
    };

    systemd.user.services.polkit-agent = {
      Unit = {
        Description = "launch authentication-agent-1";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = ''
          ${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1
        '';
      };

      Install = {WantedBy = ["graphical-session.target"];};
    };
  };
}
