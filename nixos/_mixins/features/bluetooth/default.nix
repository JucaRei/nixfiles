{ isWorkstation, pkgs, ... }: {
  hardware = {
    enableRedistributableFirmware = true;

    # https://nixos.wiki/wiki/Bluetooth
    bluetooth =
      if (isWorkstation) then {
        enable = true;
        # package = pkgs.unstable.bluez5-experimental;
        package = pkgs.unstable.bluez-experimental;
        powerOnBoot = false;
        # hsphfpd.enable = false;
        # disabledPlugins = [ "sap" ];
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
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
      } else {
        enable = true;
        package = pkgs.bluez;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = true;
          };
        };
      };
  };
}
