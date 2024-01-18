{ pkgs, ... }: {

  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = with pkgs; [
        rofi-calc
        rofi
        rofi-emoji
      ];
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
      ".config/rofi/conf/rofi-nm/rofi-network-manager.conf".text = ''
        LOCATION=3
        WIDTH_FIX_MAIN=10
        WIDTH_FIX_STATUS=10
      '';
      ".config/rofi/rofi-network-manager.rasi".text = ''
        configuration {
          show-icons:		false;
          sidebar-mode: 	false;
          hover-select: true;
          me-select-entry: "";
          me-accept-entry: [MousePrimary];
        }

        * {
            font: "Inter-MediumItalic 12";
        }

        @theme "catppuccin"

        element-text, element-icon , mode-switcher {
            background-color: inherit;
            text-color:       inherit;
        }

        window {
            height: 40%;
            width: 40%;
            border: 3px;
            border-color: @border-col;
            background-color: @bg-col;
        }

        mainbox {
            background-color: @bg-col;
        }

        inputbar {
            children: [prompt,entry];
            background-color: @bg-col;
            border-radius: 5px;
            padding: 2px;
        }

        prompt {
            background-color: @blue;
            padding: 6px;
            text-color: @bg-col;
            border-radius: 3px;
            margin: 20px 0px 0px 20px;
        }

        textbox-prompt-colon {
            expand: false;
            str: ":";
        }

        entry {
            placeholder: "";
            padding: 6px;
            margin: 20px 0px 0px 10px;
            text-color: @fg-col;
            background-color: @bg-col;
        }

        listview {
            border: 0px 0px 0px;
            padding: 6px 0px 0px;
            margin: 10px 0px 0px 20px;
            columns: 1;
            background-color: @bg-col;
        }

        element {
            padding: 5px;
            background-color: @bg-col;
            text-color: @fg-col  ;
        }

        element-icon {
            size: 25px;
        }

        element selected {
            background-color:  @selected-col ;
            text-color: @fg-col2  ;
        }

        mode-switcher {
            spacing: 0;
        }

        button {
            padding: 10px;
            background-color: @bg-col-light;
            text-color: @grey;
            vertical-align: 0.5;
            horizontal-align: 0.5;
        }

        button selected {
          background-color: @bg-col;
          text-color: @blue;
        }
      '';
    };
  };
}
