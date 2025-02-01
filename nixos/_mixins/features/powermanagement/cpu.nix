{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  cfg = config.features.powerManagement;
in
{

  config = mkIf (cfg.powerManagement == "power-profiles-daemon" || cfg.powerManagement == "auto-cpufreq") {
    boot = {
      extraModulePackages = with config.boot.kernelPackages; [
        cpupower
        pkgs.cpupower-gui
      ];
    };

    environment.systemPackages = with pkgs; [
      power-profiles-daemon
    ];

    services = {
      auto-cpufreq.enable = !config.features.powerManagement.tlp.enable;
      power-profiles-daemon.enable = !config.features.powerManagement.tlp.enable;
    };
  };
}
