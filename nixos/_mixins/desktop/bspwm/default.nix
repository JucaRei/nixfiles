{ username, pkgs, config, lib, ... }: {
  config = {
    services = {
      displayManager.defaultSession = "none+bspwm";
      xserver = {
        enable = true;
        displayManager = {
          sessionCommands = ''
            # GTK2_RC_FILES must be available to the display manager.
            export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
          '';

          # setupCommands = '''';
          lightdm = {
            enable = true;
            background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
            greeters = {
              # mini = {
              #   enable = true;
              #   user = "${username}";
              #   extraConfig = ''
              #     font-size = 1.0em
              #     font = "Iosevka"

              #     [greeter]
              #     show-password-label = false
              #     password-label-text = ""
              #     password-input-width = 30
              #     password-alignment = left
              #   '';
              # };
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
                iconTheme.name = lib.mkDefault "Yaru-magenta-dark";
                iconTheme.package = pkgs.yaru-theme;
                indicators = [
                  "~session"
                  "~host"
                  "~spacer"
                  "~clock"
                  "~spacer"
                  "~a11y"
                  "~power"
                ];
                # https://github.com/Xubuntu/lightdm-gtk-greeter/blob/master/data/lightdm-gtk-greeter.conf
                extraConfig = ''
                  # background = Background file to use, either an image path or a color (e.g. #772953)
                  font-name = Work Sans 12
                  xft-antialias = true
                  xft-dpi = 96
                  xft-hintstyle = slight
                  xft-rgba = rgb

                  active-monitor = #cursor
                  # position = x y ("50% 50%" by default)  Login window position
                  # default-user-image = Image used as default user icon, path or #icon-name
                  hide-user-image = false
                  round-user-image = false
                  highlight-logged-user = true
                  panel-position = top
                  clock-format = %a, %b %d  %H:%M
                '';
              };
            };
          };
        };
        windowManager.bspwm = {
          enable = true;
          sxhkd = {
            package = pkgs.sxhkd;
            configFile = "${pkgs.bspwm}/share/doc/bspwm/examples/sxhkdrc";
          };
        };

        resolutions = [
          {
            x = 1920;
            y = 1200;
          }
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
        pamixer
        papirus-icon-theme
        alacritty
        rxvt-unicode
      ];

      # Fix issue with java applications and tiling window managers.
      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
      };
    };

    services = {
      udev = {
        extraRules = ''
          ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video %S%p/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w %S%p/brightness"
        '';
      };
    };

    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        configPackages = [ pkgs.gnome.gnome-session ];
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = [ "gnome" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        };
      };
      terminal-exec = {
        enable = true;
        settings = {
          default = [ "alacritty.desktop" ];
        };
      };
    };
  };
}
