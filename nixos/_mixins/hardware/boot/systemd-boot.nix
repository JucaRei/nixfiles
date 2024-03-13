_: {
  boot = {
    initrd.systemd.enable = true;
    loader = {
      efi = {
        canTouchEfiVariables = false;
        # efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        editor = true;
        configurationLimit = 4;
        #consoleMode = "max";
        memtest86.enable = true;
      };
      timeout = 5;
    };
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };
}
