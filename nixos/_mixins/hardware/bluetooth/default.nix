{pkgs, ...}: {
  # https://nixos.wiki/wiki/Bluetooth
  hardware = {
    bluetooth = {
      enable = true;
      # package = pkgs.bluez;

      # battery info support
      package = pkgs.bluez5-experimental;

      powerOnBoot = false;
      disabledPlugins = ["sap"];
      hsphfpd.enable = false;
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
          Experimental = true; # for gnome-bluetooth percentage
        };
      };
    };
  };
  # https://github.com/NixOS/nixpkgs/issues/114222
  systemd.user.services.telephony_client.enable = false;
}
