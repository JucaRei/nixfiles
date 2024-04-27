{ username, pkgs, config, lib, ... }: {
  services = {
    xserver = {
      enable = true;
      displayManager = {
        # defaultSession = "none+fake";
        defaultSession = "none+bspwm";
        session = [
          {
            # name = "fake";
            name = "bspwm";
            manage = "window";
            start = "bspwm";
          }
        ];
        sessionCommands = ''
          # GTK2_RC_FILES must be available to the display manager.
          export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
        '';

        # setupCommands = '''';
        lightdm = {
          enable = true;
          background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
          greeters = {
            mini = {
              enable = true;
              user = "${username}";
            };
            gtk = {
              theme = {
                name = "Dracula";
                package = pkgs.dracula-theme;
                # package = pkgs.tokyo-night-gtk;
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
      windowManager.bspwm.enable = true;

      resolutions = [
        {
          x = 1920;
          y = 1080;
        }
        {
          x = 1600;
          y = 900;
        }
        {
          x = 1366;
          y = 768;
        }
      ];
    };

    # getty = {
    #   autologinUser = "${username}";
    # };

    tumbler.enable = true; # get thumbnails in ristretto
  };

  environment = {
    systemPackages = with pkgs; [
      # xclip # Clipboard
      # kitty
      pamixer
      # i3lock-fancy
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

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      # extraPortals = with pkgs; lib.mkForce [ xdg-desktop-portal-gnome ];
      config = {
        common = { default = [ "gtk" ]; };
        gnome = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };
  };

  # this may be needed in some cases
  programs.dconf.enable = true;

  services = {
    gnome.gnome-keyring.enable = true;
    udev = {
      extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video %S%p/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w %S%p/brightness"
      '';
    };
  };
}
