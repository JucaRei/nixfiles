{ pkgs, ... }: {
  # https://nixos.wiki/wiki/Bluetooth
  hardware = {
    bluetooth = {
      enable = true;
      # package = pkgs.bluezFull;

      # battery info support
      package = pkgs.bluez5-experimental;

      powerOnBoot = false;
      disabledPlugins = [ "sap" ];
      hsphfpd.enable = false;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
          # make Xbox Series X controller work
          #Class = "0x000100";
          #ControllerMode = "bredr";
          #FastConnectable = true;
          #JustWorksRepairing = "always";
          #Privacy = "device";
          #Experimental = true;
        };
      };
    };
  };
}
