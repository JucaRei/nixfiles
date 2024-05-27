{ config, lib, pkgs, ... }:
with lib; {
  options =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      services.polkit-agent = {
        enable = mkEnableOption "Service polkit agent";
        package = mkOption {
          type = types.package;
          default = pkgs.pantheon.pantheon-agent-polkit;
          # default = pkgs.lxqt.lxqt-policykit;
          defaultText = literalExample "pkgs.pantheon.pantheon-agent-polkit";
          # defaultText = literalExample "pkgs.lxqt.lxqt-policykit";
          description = ''
            The Polkit agent package to use.
          '';
        };
        executablePath = mkOption {
          type = types.str;
          default = "libexec/policykit-1-pantheon/io.elementary.desktop.agent-polkit";
          # default = "bin/lxqt-policykit-agent";
          description = ''
            The path to the Polkit agent executable within `package`.
          '';
        };
        systemd.target = mkOption {
          type = types.str;
          default = "graphical-session.target";
          description = "The systemd target that will automatically start the Polkit agent service.";
        };
      };
    };

  config =
    let
      cfg = config.services.polkit-agent;
      inherit (lib) mkIf;
    in
    mkIf cfg.enable {
      home.packages = [ cfg.package ];

      systemd.user.services.polkit-agent = {
        Unit = {
          Description = "Polkit agent";
          Documentation = "https://gitlab.freedesktop.org/polkit/polkit/";
          # After = [ "graphical-session-pre.target" ];
          PartOf = [ cfg.systemd.target ];
          After = [ cfg.systemd.target ];
        };

        Service = {
          ExecStart = "${cfg.package}/${cfg.executablePath}";
          # Restart = "always";
          BusName = "org.freedesktop.PolicyKit1.Authority";
        };

        Install = { WantedBy = [ cfg.systemd.target ]; };
      };
    };
}

#  services.bspwm-polkit-authentication-agent = {
#    Unit = {
#      Description = "Bspwm Polkit authentication agent";
#      Documentation = "https://gitlab.freedesktop.org/polkit/polkit/";
#      After = [ "graphical-session-pre.target" ];
#      PartOf = [ "graphical-session.target" ];
#    };

#    Service = {
#      ExecStart = "${pkgs.lxde.lxsession}/bin/lxpolkit";
#      # ExecStart = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
#      Restart = "always";
#      BusName = "org.freedesktop.PolicyKit1.Authority";
#    };

#    Install.WantedBy = [ "graphical-session.target" ];
#  };

# services.polkit-agent = {
# services.lxpolkit = {
#   Unit = {
#     # Description = "launch authentication-agent-1";
#     Description = "launch lxpolkit";
#     After = [ "graphical-session.target" ];
#     PartOf = [ "graphical-session.target" ];
#   };
#   Service = {
#     Type = "simple";
#     Restart = "on-failure";
#     RestartSec = 1;
#     # exec --no-startup-id ${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1
#     # exec export DISPLAY=:0
#     # exec "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY"
#     ExecStart = getExe pkgs.lxqt.lxqt-policykit;
#     TimeoutStopSec = 10;
#   };

#   Install = { WantedBy = [ "graphical-session.target" ]; };
# };
