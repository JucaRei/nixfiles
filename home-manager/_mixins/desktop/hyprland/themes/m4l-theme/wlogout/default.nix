_: {
  programs = {
    wlogout = {
      enable = true;
      layout = [
        {
          "label" = "lock";
          "action" = "sleep 1; swaylock";
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
          # "action" = "sleep 1; hyprctl dispatch exit";  # SDDM
          "action" = "sleep 1; loginctl terminate-user $USER";
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
      style = ''
        /*
                  _                         _
        __      _| | ___   __ _  ___  _   _| |_
        \ \ /\ / / |/ _ \ / _` |/ _ \| | | | __|
         \ V  V /| | (_) | (_| | (_) | |_| | |_
          \_/\_/ |_|\___/ \__, |\___/ \__,_|\__|
                          |___/

        */

        /* -----------------------------------------------------
         * Import Pywal colors
         * ----------------------------------------------------- */
        # @import '../../.cache/wal/colors-wlogout.css';

        @define-color foreground #caccc9;
        @define-color background #0B0C07;
        @define-color cursor #caccc9;

        @define-color color0 #0B0C07;
        @define-color color1 #66605A;
        @define-color color2 #6B6E66;
        @define-color color3 #B03F41;
        @define-color color4 #7B837B;
        @define-color color5 #9F8182;
        @define-color color6 #8A928B;
        @define-color color7 #caccc9;
        @define-color color8 #8d8e8c;
        @define-color color9 #66605A;
        @define-color color10 #6B6E66;
        @define-color color11 #B03F41;
        @define-color color12 #7B837B;
        @define-color color13 #9F8182;
        @define-color color14 #8A928B;
        @define-color color15 #caccc9;

        /* -----------------------------------------------------
         * General
         * ----------------------------------------------------- */

        * {
            font-family: "Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
        	background-image: none;
        	transition: 20ms;
        }

        window {
        	background-color: rgba(12, 12, 12, 0.1);
        }

        button {
        	color: #FFFFFF;
            font-size:20px;

            background-repeat: no-repeat;
        	background-position: center;
        	background-size: 25%;

        	border-style: solid;
        	background-color: rgba(12, 12, 12, 0.3);
        	border: 3px solid #FFFFFF;

            box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
        }

        button:focus,
        button:active,
        button:hover {
            color: @color11;
        	background-color: rgba(12, 12, 12, 0.5);
        	border: 3px solid @color11;
        }

        /*
        -----------------------------------------------------
        Buttons
        -----------------------------------------------------
        */

        #lock {
        	margin: 10px;
        	border-radius: 20px;
        	background-image: image(url("icons/lock.png"));
        }

        #logout {
        	margin: 10px;
        	border-radius: 20px;
        	background-image: image(url("icons/logout.png"));
        }

        #suspend {
        	margin: 10px;
        	border-radius: 20px;
        	background-image: image(url("icons/suspend.png"));
        }

        #hibernate {
        	margin: 10px;
        	border-radius: 20px;
        	background-image: image(url("icons/hibernate.png"));
        }

        #shutdown {
        	margin: 10px;
        	border-radius: 20px;
        	background-image: image(url("icons/shutdown.png"));
        }

        #reboot {
        	margin: 10px;
        	border-radius: 20px;
        	background-image: image(url("icons/reboot.png"));
        }

      '';
    };
  };
}
