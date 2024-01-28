{ pkgs, ... }: {
  services = {
    xserver = {
      enable = true;
      windowManager = { awesome = { enable = true; }; };
      displayManager = {
        defaultSession = "none+fake";
        session = [{
          name = "fake";
          manage = "window";
          start = "bspwm";
        }];
        lightdm = {
          enable = true;
          background =
            pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
        };
      };
    };
  };

  security = {
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
  };
}
