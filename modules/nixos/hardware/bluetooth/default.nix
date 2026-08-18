{ config, lib, pkgs, isInstall, isWorkstation, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf isInstall {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.unstable.bluez-experimental;
      powerOnBoot = false;
      settings = {
        General = mkIf isWorkstation {
          Name = config.networking.hostName;
          Enable = "Source,Sink,Media,Socket"; # Enable A2DP sink
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
          ControllerMode = "bredr";
          FastConnectable = true;
          Privacy = "device";
          Experimental = true;
        };
      };
    };

    system.activationScripts.rfkillUnblockBluetooth = mkIf config.hardware.bluetooth.enable {
      text = ''
        # Unblock Bluetooth on activation
        ${pkgs.util-linux}/bin/rfkill unblock bluetooth || true
      '';
    };
  };
}
