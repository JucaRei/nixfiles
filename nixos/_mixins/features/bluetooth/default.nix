{ isWorkstation, pkgs, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.features.bluetooth;
in
{
  options.features.bluetooth = {
    enable = mkEnableOption "Whether enable bluetooth";
    default = isWorkstation;
  };

  config = mkIf cfg.enable {
    hardware = {
      # https://nixos.wiki/wiki/Bluetooth
      bluetooth = {
        enable = true;
        package = pkgs.unstable.bluez-experimental;
        powerOnBoot = false;
        # hsphfpd.enable = false;
        # disabledPlugins = [ "sap" ];
        settings = {
          General = {
            Name = config.networking.hostName;
            Enable = "Source,Sink,Media,Socket"; # Enable A2DP sink
            JustWorksRepairing = "always";
            MultiProfile = "multiple";
            # make Xbox Series X controller work
            Class = "0x000100";
            ControllerMode = "bredr";
            FastConnectable = true;
            Privacy = "device";
            Experimental = true;
          };
        };
      };
    };
    system.activationScripts = {
      rfkillUnblockBluetooth.text = ''
        rfkill unblock bluetooth
      '';
    };
  };
}
