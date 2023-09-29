### NixOS module that provides hourly notifications when a reboot is needed for a kernel, initrd, or kernel-module upgrade
{ pkgs, ... }:
let
  readlink = "${pkgs.coreutils}/bin/readlink";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
in
{
  systemd.user.services.detect-reboot-for-upgrade = {
    script = ''
      set -eu -o pipefail

      booted="$(${readlink} /run/booted-system/{initrd,kernel,kernel-modules})"
      built="$(${readlink} /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"

      if [[ "''${booted}" != "''${built}" ]];
      then
        echo "Looks like we need a reboot!"
        ${notify-send} --urgency=low --icon=system-reboot "Reboot is needed for a NixOS upgrade."
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
  systemd.user.timers.detect-reboot-for-upgrade = {
    wantedBy = [ "timers.target" ];
    partOf = [ "detect-reboot-for-upgrade.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "detect-reboot-for-upgrade.service";
    };
  };
}
