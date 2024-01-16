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
    };
  };
}
