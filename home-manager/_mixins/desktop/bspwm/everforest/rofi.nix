{ pkgs, lib, ... }: {
  enable = true;
  plugins = with pkgs; [
    rofi-pass
    rofi-calc
    rofi-power-menu
  ];
}
