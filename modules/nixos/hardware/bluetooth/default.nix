{
  config,
  lib,
  pkgs,
  isInstall,
  isWorkstation,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf isInstall {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.unstable.bluez-experimental;
      powerOnBoot = mkDefault true;
      settings = {
        General = mkIf isWorkstation {
          Name = config.networking.hostName;
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
          ControllerMode = "dual"; # Essencial: permite tanto Bluetooth clássico quanto Low Energy (BLE para MX Keys e mouses)
          FastConnectable = true;
          Privacy = "device";
          Experimental = true;
        };
        Policy = {
          AutoEnable = "true";
          ReconnectAttempts = 7;
          ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
        };
      };
    };

    services.blueman.enable = mkDefault isWorkstation;

    system.activationScripts.rfkillUnblockBluetooth = mkIf config.hardware.bluetooth.enable {
      text = ''
        # Unblock Bluetooth on activation
        ${pkgs.util-linux}/bin/rfkill unblock bluetooth || true
      '';
    };
  };
}
