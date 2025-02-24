{ config, hostname, isWorkstation, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;
  # Declare which hosts have Maestral (Dropbox) enabled.
  installOn = [ "soyo" ];
  cfg = config.system.services.maestral;
in
# lib.mkIf (lib.elem "${hostname}" installOn) {
{
  options = {
    system.services.maestral = {
      enable = mkOption {
        default = false;
        type = bool;
        description = "Enable Maestral (Dropbox)";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ maestral ];

    systemd.user.services.maestral = {
      description = "Maestral";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.maestral}/bin/maestral start";
        ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
        KillMode = "process";
        Restart = "on-failure";
      };
    };

    systemd.user.services.maestral-gui = lib.mkIf isWorkstation {
      description = "Maestral GUI";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.maestral-gui}/bin/maestral_qt";
        ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
        KillMode = "process";
        Restart = "on-failure";
      };
    };
  };
}
