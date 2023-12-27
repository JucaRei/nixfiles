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
    };
  };
}
