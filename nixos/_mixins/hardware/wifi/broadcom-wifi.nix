{
  config,
  pkgs,
  ...
}: {
  boot = {
    # initrd = {
    #   kernelModules = [ "wl" ];
    # };
    kernelModules = ["wl" "b43"];
    extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
  };
  hardware = {
    enableAllFirmware = true;
    firmware = [pkgs.b43Firmware_5_1_138];
  };
}
