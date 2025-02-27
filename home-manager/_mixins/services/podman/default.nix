{ lib, ... }:
{
  services = {
    podman = {
      enable = true;
      # autoUpdate = {
      # enable = true;
      # onCalendar = "*-*-* 00:00:00";
      # };
      # containers = { };
    };
  };
  home = {
    shellAliases = {
      docker = "podman";
    };
  };
  systemd.user.services."user@".serviceConfig = {
    Delegate = "cpu cpuset io memory pids";
  };
}
