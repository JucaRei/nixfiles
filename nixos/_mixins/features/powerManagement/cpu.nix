{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  cfg = config.features.powerManagement;
in
{

  config = mkIf (cfg.powerProfiles == "power-profiles-daemon") {
    boot = {
      extraModulePackages = with config.boot.kernelPackages; [
        # cpupower
        # pkgs.cpupower-gui
      ];
    };

    environment.systemPackages = with pkgs; [
      power-profiles-daemon
    ];

    services = {
      power-profiles-daemon.enable = if (config.features.powerManagement.powerProfiles != "tlp" || "auto-cpufreq") then true else false;
    };
  };
}
