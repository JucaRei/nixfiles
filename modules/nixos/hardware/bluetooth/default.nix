{ config, lib, namespace, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.hardware.bluetooth;
in
{
  options.${namespace}.hardware.bluetooth = {
    enable = mkEnableOption "Enable bluetooth service and packages";
  };

  config = mkIf cfg.enable {
    services.blueman.enable = true;
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = false;
        package = pkgs.unstable.bluez-experimental;
        settings = {
          General = {
            Experimental = true;
            Name = config.networking.hostName;
            Enable = "Source,Sink,Media,Socket"; # Enable A2DP sink
            JustWorksRepairing = "always";
            MultiProfile = "multiple";
            # # make Xbox Series X controller work
            Class = "0x000100";
            ControllerMode = "bredr";
            FastConnectable = true;
            Privacy = "device";
          };
        };
      };
    };
  };
}
