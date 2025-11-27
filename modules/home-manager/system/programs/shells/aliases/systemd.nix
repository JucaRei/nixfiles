# programs/terminal/console/aliases/systemd.nix
{ lib, pkgs }:
let

  mkSys = c: { name = "sc-${c}"; value = "systemctl ${c}"; };
  mkUser = c: { name = "scu-${c}"; value = "systemctl --user ${c}"; };
  mkSudo = c: { name = "sc-${c}"; value = "sudo systemctl ${c}"; };

  userCmds = [ "cat" "help" "status" "show" "list-units" "list-unit-files" "is-active" "is-enabled" "is-failed" ];
  sudoCmds = [ "start" "stop" "restart" "reload" "enable" "disable" "mask" "daemon-reload" "poweroff" "reboot" ];
  powerCmds = [ "reboot" "poweroff" "suspend" "hibernate" "hybrid-sleep" ];
in
builtins.listToAttrs
  (lib.flatten [
    (builtins.map mkSys (userCmds ++ powerCmds))
    (builtins.map mkUser userCmds)
    (builtins.map mkSudo sudoCmds)
  ]) // {
  # Handy extras
  sc-failed = "systemctl --failed";
  sc-enable-now = "sc-enable --now";
  sc-disable-now = "sc-disable --now";
  scu-failed = "systemctl --user --failed";

  jc-boot = "journalctl -b";
  jc-service = "journalctl -u";
  jcu-service = "journalctl --user -u";
}
