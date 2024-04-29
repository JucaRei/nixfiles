{ pkgs, lib, ... }: {
  enable = true;
  plugins = with pkgs; [
    rofimoji
    rofi-pass
    rofi-calc
    rofi-bluetooth
    rofi-power-menu
    rofi-screenshot
    pinentry-rofi
  ];
}
