{ username, pkgs, config, lib, ... }: {

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
      libinput = {
        enable = true;
        touchpad = {
          tapping = lib.mkDefault true;
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
      # kitty
      pamixer
      i3lock-fancy
      papirus-icon-theme
      # bsp-layout
      # betterlockscreen
      # gamemode
      # gnomeExtensions.gamemode
      # xorg.xev # Event Viewer
      # xorg.xkill # Process Killer
      # xorg.xrandr # Monitor Settings
      # xorg.xinit
      # xorg.xsetroot
      # python311Packages.xdg
      # python311Packages.pytz
      # xfce.xfce4-settings
      xfce.xfce4-power-manager
    ];

    # sessionVariables = rec {
    #   XDG_CACHE_HOME = "$HOME/.cache";
    #   XDG_CONFIG_HOME = "$HOME/.config";
    #   XDG_DATA_HOME = "$HOME/.local/share";
    #   XDG_STATE_HOME = "$HOME/.local/state";

    #   # Not officially in the specification
    #   XDG_BIN_HOME = "$HOME/.local/bin";
    #   PATH = [
    #     "${XDG_BIN_HOME}"
    #   ];
    # };
  };
}
