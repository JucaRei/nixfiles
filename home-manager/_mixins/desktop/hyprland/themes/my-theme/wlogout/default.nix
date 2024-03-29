{pkgs, ...}: let
  ui = import ./ui.nix {};
in {
  xdg.configFile."wlogout/icons".source = ./assets;
  programs = {
    wlogout = {
      enable = true;
      layout = [
        {
          "label" = "lock";
          "action" = "sleep 1; swaylock";
          # action = "${pkgs.lockman}/bin/lockman.sh ";
          "text" = "Lock";
          "keybind" = "l";
        }
        {
          "label" = "hibernate";
          "action" = "sleep 1; systemctl hibernate";
          "text" = "Hibernate";
          "keybind" = "h";
        }
        {
          "label" = "logout";
          "action" = "sleep 1; hyprctl dispatch exit"; # SDDM
          # "action" = "sleep 1; loginctl terminate-user $USER";
          "text" = "Exit";
          "keybind" = "e";
        }
        {
          "label" = "shutdown";
          "action" = "sleep 1; systemctl poweroff";
          "text" = "Shutdown";
          "keybind" = "s";
        }
        {
          "label" = "suspend";
          "action" = "sleep 1; systemctl suspend";
          "text" = "Suspend";
          "keybind" = "u";
        }
        {
          "label" = "reboot";
          "action" = "sleep 1; systemctl reboot";
          "text" = "Reboot";
          "keybind" = "r";
        }
      ];
      style = with ui; ''
        window {
                  font-family: ${font};
                  font-size: 16px;
                  color: #${foreground-color};
                  background-color: rgba(0, 0, 0, 0.5);
              }
              button {
                  background-repeat: no-repeat;
                  background-position: center;
                  background-size: 35%;
                  border: none;
                  background-color: rgba(0, 0, 0, 0);
                  margin: 5px;
                  border-radius: 0px;
                  transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
              }
              button:hover {
                  background-color: #${colors.background};
              }
              button:focus {
                  background-color: #${colors.background};
                  border: ${toString border-size}px solid #${border-color};
                  border-radius: ${toString border-radius}px;
                  color: #${foreground-color};
              }
              /** ********** Icons ********** **/
              #lock {
                  background-image: image(url("icons/lock.png"), url("/usr/share/wlogout/icons/lock.png"));
              }

              #logout {
                  background-image: image(url("icons/logout.png"), url("/usr/share/wlogout/icons/logout.png"));
              }

              #suspend {
                  background-image: image(url("icons/suspend.png"), url("/usr/share/wlogout/icons/suspend.png"));
              }

              #hibernate {
                  background-image: image(url("icons/hibernate.png"), url("/usr/share/wlogout/icons/hibernate.png"));
              }

              #shutdown {
                  background-image: image(url("icons/shutdown.png"), url("/usr/share/wlogout/icons/shutdown.png"));
              }

              #reboot {
                  background-image: image(url("icons/reboot.png"), url("/usr/share/wlogout/icons/reboot.png"));
              }
      '';
    };
  };
}
