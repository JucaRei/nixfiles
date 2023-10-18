{ username, pkgs, config, ... }: {
  services = {
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "none+fake";
        session = [{
          name = "fake";
          manage = "window";
          start = "bspwm";
        }];
        # setupCommands = '''';
        lightdm = {
          enable = true;
          greeter = {
            enable = true;
            background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
            gtk = {
                theme = {
                  name = "Dracula";
                  package = pkgs.dracula-theme;
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

      resolutions = [
          { x = 1920; y = 1080; }
          { x = 1600; y = 900; }
          { x = 1366; y = 768; }
        ];
      };
    };

    # getty = {
    #   autologinUser = "${username}";
    # };
  };

  environment = {
    systemPackages = with pkgs; [
      xclip             # Clipboard
      xorg.xev          # Event Viewer
      xorg.xkill        # Process Killer
      xorg.xrandr       # Monitor Settings
      xorg.xsetroot
      xfce.xfce4-terminal
      pamixer
      i3lock-fancy
    ];
  };

  # xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
}
