{ pkgs, config, ... }: {
  services.xserver = {
    enable = true;
    desktopManager.lxqt = {
      enable = true;
    };
    displayManager = {
      sddm = {
        enable = true;
      };
      defaultSession = "lxqt";
      autoLogin = {
        enable = false;
      };
    };
  };
}
