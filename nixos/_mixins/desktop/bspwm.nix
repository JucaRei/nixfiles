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
          background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
          greeters = {
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
      libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          scrollMethod = "twofinger";
          naturalScrolling = true;
          accelProfile = "adaptive";
          disableWhileTyping = true;
          sendEventsMode = "disabled-on-external-mouse";
        };
        mouse = {
          scrollMethod = "button";
        };
      };

      resolutions = [
        { x = 1920; y = 1080; }
        { x = 1600; y = 900; }
        { x = 1366; y = 768; }
      ];
    };

    # getty = {
    #   autologinUser = "${username}";
    # };
  };

  environment = {
    systemPackages = with pkgs; [
      xclip # Clipboard
      kitty
      pamixer
      i3lock-fancy
      papirus-icon-theme
      bsp-layout
      dunst
      rofi
      sxhkd
      polybar
      gamemode
      gnomeExtensions.gamemode
    ] ++ pkgs.xorg [
      xev # Event Viewer
      xkill # Process Killer
      xrandr # Monitor Settings
      xinit
      xsetroot
    ] ++ pkgs.python311Packages [
      xdg
      pytz
      pip
    ] ++ pkgs.xfce [
      xfce4-settings
      xfce4-power-manager
    ];
  };
}
