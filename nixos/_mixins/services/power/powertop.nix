_: {
  powerManagement.powertop.enable = true;
  # FIXME always coredumps on boot
  systemd.services.powertop.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "2s";
  };
}
