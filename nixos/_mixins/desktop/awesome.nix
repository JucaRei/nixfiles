{ pkgs, ... }: {
  services = {
    xserver = {
      windowManager.awesome = {
        enable = true;
      displayManager = {
        defaultSession = "none+fake";
        session = [{
          name = "fake";
          manage = "window";
          start = "awesome";
        }];
        lightdm = {
          enable = true;
          background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
          greeters = {
            # mini = {
            #   enable = true;
            # };
            gtk = {
              theme = {
                name = "Dracula";
                # package = pkgs.dracula-theme;
                package = pkgs.tokyo-night-gtk;
              };
              cursorTheme = {
                name = "Dracula-cursors";
                package = pkgs.dracula-theme;
                size = 16;
              };
            };
          };
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
