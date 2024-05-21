{ config, lib, pkgs, ... }: {
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
          defaultText = "pkgs.pantheon.pantheon-agent-polkit";
          description = ''
            The Polkit agent package to use.
          '';
        };
        executablePath = mkOption {
          type = types.str;
          default = "libexec/policykit-1-pantheon/io.elementary.desktop.agent-polkit";
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
          PartOf = [ cfg.systemd.target ];
          After = [ cfg.systemd.target ];
        };

        Service = {
          ExecStart = "${cfg.package}/${cfg.executablePath}";
          Restart = "always";
          BusName = "org.freedesktop.PolicyKit1.Authority";
        };

        Install = { WantedBy = [ cfg.systemd.target ]; };
      };
    };
}