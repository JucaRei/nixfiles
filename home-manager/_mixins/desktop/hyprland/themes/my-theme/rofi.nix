{ pkgs, ... }: {

  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = with pkgs; [ rofi-calc rofi rofi-emoji ];
    };
  };
  home = {
    file = {
      ".config/rofi" = {
        source = ../../../../config/hyprland/rofi;
        recursive = true;
      };
      ".config/rofi/scripts/bravebookmarks.sh" = {
        text = ''
          selected=$(cat ~/.config/BraveSoftware/Brave-Browser/Default/Bookmarks | grep '"url":' | awk '{print $2}' | sed 's/"//g' | rofi -dmenu -p "Select a Brave Bookmark")

          if [ "$selected" ]; then
              brave $selected
          fi
        '';
        executable = true;
      };
      ".config/rofi/scripts/bluetooth-control.sh" = {
        source = ./rofi/bluetooth-control.sh;
        executable = true;
      };
      ".config/rofi/scripts/rofi-bluetooth.sh" = {
        source = ./rofi/rofi-bluetooth.sh;
        executable = true;
      };
      ".config/rofi/scripts/rofi-nm.sh" = {
        source = ../../../../config/rofi/scripts/rofi-nm.sh;
        executable = true;
      };
      ".config/rofi/conf/rofi-network-manager.conf".text = ''
                # Location
        #This sets the anchor point:
        # +---------- +
        # | 1 | 2 | 3 |
        # | 8 | 0 | 4 |
        # | 7 | 6 | 5 |
        # +-----------+
        #If you want the window to be in the upper right corner, set location to 3.
        LOCATION=3
        QRCODE_LOCATION=$LOCATION
        #X, Y Offset
        Y_AXIS=0
        X_AXIS=0
        #Use notifications or not
        # Values on / off
        NOTIFICATIONS_INIT="on"
        #Location of qrcode wifi image
        QRCODE_DIR="/tmp/"
        #WIDTH_FIX_MAIN/WIDTH_FIX_STATUS needs to be increased or decreased , if the text
        #doesn't fit or it has too much space at the end when you launch rofi-network-manager.
        #It depends on the font type and size.
        WIDTH_FIX_MAIN=3
        WIDTH_FIX_STATUS=6
      '';
      ".config/rofi/rofi-network-manager.rasi".text = ''
        /*******************************************************************************
         * MACOS SPOTLIGHT LIKE DARK THEME FOR ROFI
         * User                 : LR-Tech
         * Theme Repo           : https://github.com/lr-tech/rofi-themes-collection
         *******************************************************************************/

        * {
            font:   "JetBrainsMono 12";

            bg0:    #242424E6;
            bg1:    #7E7E7E80;
            bg2:    #0860f2E6;

            fg0:    #DEDEDE;
            fg1:    #FFFFFF;
            fg2:    #DEDEDE80;

            background-color:   transparent;
            text-color:         @fg0;

            margin:     0;
            padding:    0;
            spacing:    0;
        }

        window {
            background-color:   @bg0;

            location:       center;
            width:          640;
            border-radius:  8;
        }

        inputbar {
            font:       "JetBrainsMono 12";
            padding:    12px;
            spacing:    12px;
            children:   [ icon-search, entry ];
        }

        icon-search {
            expand:     false;
            filename:   "network";
            size: 12px;
        }

        icon-search, entry, element-icon, element-text {
            vertical-align: 0.5;
        }

        entry {
            font:   inherit;

            placeholder         : "SSID";
            placeholder-color   : @fg2;
        }

        message {
            border:             2px 0 0;
            border-color:       @bg1;
            background-color:   @bg1;
        }

        textbox {
            padding:    8px 24px;
        }

        listview {
            lines:      10;
            columns:    1;

            fixed-height:   false;
            border:         1px 0 0;
            border-color:   @bg1;
        }

        element {
            padding:            8px 16px;
            spacing:            16px;
            background-color:   transparent;
        }

        element normal active {
            text-color: @bg2;
        }

        element selected normal, element selected active {
            background-color:   @bg2;
            text-color:         @fg1;
        }

        element-icon {
            size:   1em;
        }

        element-text {
            text-color: inherit;
        }

        /*****----- Main Window -----*****/
        window {
            /* properties for window widget */
            transparency:                "real";
            location:                    north east;
            anchor:                      north east;
            fullscreen:                  false;
            width:                       400px;
            x-offset:                    0px;
            y-offset:                    0px;

            /* properties for all widgets */
            enabled:                     true;
            margin:                      0px;
            padding:                     0px;
            border:                      0px solid;
            border-radius:               10px;
            cursor:                      "default";
            /* Backgroud Colors */
            background-color:            @bg0;
           /* Backgroud Image */
            //background-image:          url("/path/to/image.png", none);
            /* Simple Linear Gradient */
            //background-image:          linear-gradient(red, orange, pink, purple);
            /* Directional Linear Gradient */
            //background-image:          linear-gradient(to bottom, pink, yellow, magenta);
            /* Angle Linear Gradient */
            //background-image:          linear-gradient(45, cyan, purple, indigo);
        }
      '';
    };
  };
}
