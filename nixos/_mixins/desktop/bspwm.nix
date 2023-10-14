{ username, pkgs, ... }: {
  services = {
    xserver = {
      enable = true;
      ### Enable bspwm
      windowManager.bspwm = {
        enable = true;
      };
      displayManager = {
        defaultSession = "none+bspwm";
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
          disableWhileTyping = true;
          sendEventsMode = "disabled-on-external-mouse";
        };
      };
    };

    getty = {
      autologinUser = "${username}";
    };
  };

  environment = {
    systemPackages = with pkgs; [
      xfce.xfce4-terminal
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # provides a XDG Portals implementation.
    ];
  };
}
