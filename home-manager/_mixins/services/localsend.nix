{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.localsend;
in
{
  options.services.localsend = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    # https://localsend.org/
    home.packages = with pkgs;
      [ localsend ];

    systemd.user.services = {
      localsend = {
        Unit = { Description = "LocalSend"; };
        Service = {
          ExecStart = "${pkgs.localsend}/bin/localsend";
          Restart = "on-failure";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
    };
  };
}
