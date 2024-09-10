{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.custom.services.keybase;
in
{
  options.custom.services.keybase = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ keybase-gui ];

    systemd.user.services = {
      keybase-gui = {
        Unit = { Description = "Keybase GUI"; };
        Service = {
          ExecStart = "${pkgs.keybase-gui}/bin/keybase-gui";
          Restart = "on-failure";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
    };
  };
}
