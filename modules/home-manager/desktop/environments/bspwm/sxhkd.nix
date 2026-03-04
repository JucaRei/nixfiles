{ config, ... }: {
  services = {
    sxhkd = {
      enable = true;
      keybindings = {
        "super + Return" = "alacritty";
        "super + d" = "rofi -show drun";
        "super + shift + q" = "bspc quit";
      };
    };
  };
}
