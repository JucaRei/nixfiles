{ username, pkgs, ... }: {
  services = {
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "none+fake";
        session = [{
          name = "fake";
          manage = "window";
          start = "";
        }];
        # setupCommands = '''';
        lightdm = {
          enable = true;
          greeter = {
            enable = true;
          };
        };
      };
      libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          scrollMethod = "twofinger";
          naturalScrolling = false;
          accelProfile = "adaptive";
          disableWhileTyping = true;
          sendEventsMode = "disabled-on-external-mouse";
        };
      };
    };

    # getty = {
    #   autologinUser = "${username}";
    # };
  };

  environment = {
    systemPackages = with pkgs; [
      xorg.xsetroot
      xfce.xfce4-terminal
      pamixer
      i3lock-fancy
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # provides a XDG Portals implementation.
    ];
  };
}
