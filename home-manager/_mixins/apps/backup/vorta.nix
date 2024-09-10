{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.custom.apps.vorta;
in
{
  options.custom.apps.vorta = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [ borgbackup vorta ];

    systemd.user.services = {
      vorta = {
        Unit = { Description = "Vorta"; };
        Service = {
          ExecStart = "${pkgs.vorta}/bin/vorta --daemonise";
          Restart = "on-failure";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
    };
  };
}
