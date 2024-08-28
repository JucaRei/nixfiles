{ config
, lib
, pkgs
, namespace
, ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.hardware.bluetooth;
in
{
  options.${namespace}.hardware.bluetooth = {
    enable = mkBoolOpt false "Whether or not to enable support for extra bluetooth devices.";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;

      package = pkgs.bluez-experimental;
      powerOnBoot = true;

      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
          JustWorksRepairing = "always";
          MultiProfile = "multiple";

          # make Xbox Series X controller work
          Class = "0x000100";
          ControllerMode = "bredr";
          FastConnectable = true;
          Privacy = "device";
        };
      };
    };

    boot.kernelParams = [ "btusb" ];

    services.blueman = {
      enable = true;
    };
  };
}
