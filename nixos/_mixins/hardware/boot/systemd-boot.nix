_: {
  boot = {
    loader = {
      efi = {
        #canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
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
  };
}
