{ config, lib, pkgs, isWorkstation, ... }:

let
  cfg = config.features.powerManagement;
in
with lib;
{
  config = mkIf (cfg.enable && cfg.powerProfiles != "tlp") {
    environment.systemPackages = with pkgs; [
      powertop
    ];

    systemd = {
      services = {
        powertop = mkIf cfg.startup {
          wantedBy = [ "multi-user.target" ];
          after = [ "multi-user.target" ];
          description = "Powertop tunings";
          path = [ pkgs.kmod ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = "yes";
            ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
          };
        };
      };
    };
  };
}
