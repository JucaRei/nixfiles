{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkForce mkEnableOption;
  cfg = config.services.bluetooth;
in
{
  options = {
    services.bluetooth = {
      enable = mkEnableOption "Enable's bluetooth.";
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.unstable.bluez-experimental;
      powerOnBoot = false;
      settings = {
        General = {
          Name = config.networking.hostName;
          Enable = "Source,Sink,Media,Socket"; # Enable A2DP sink
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
          # make Xbox Series X controller work
          Class = "0x000100";
          ControllerMode = "dual"; # Changed from "bredr" to support BLE
          FastConnectable = true;
          Privacy = "device";
          Experimental = true;
          KernelExperimental = true; # NEW: For kernel experimental features
        };
        Policy = {
          AutoEnable = true;
          ReconnectAttempts = 7;
          ReconnectIntervals = "1,2,4,8,16,32,64";
        };
        LE = {
          MinConnectionInterval = 7;
          MaxConnectionInterval = 9;
          ConnectionLatency = 0;
        };
      };
    };
    system.activationScripts = {
      rfkillUnblockBluetooth.text = mkForce ''
        rfkill unblock bluetooth
      '';
    };
  };
}
