{ pkgs, lib, config, hostname, ... }:
let
  vars = import ../vars.nix { inherit pkgs config hostname; };
  _ = lib.getExe;
in
{
  enable = true;
  # font =
  plugins = with pkgs; [
    rofimoji
    rofi-calc
    rofi-bluetooth
    rofi-power-menu
    rofi-screenshot
    pinentry-rofi
  ];
  pass = {
    enable = true;
    package = pkgs.rofi-pass;
    extraConfig = ''
      # workaround for https://github.com/carnager/rofi-pass/issues/226
      help_color="#FF0000"'';
  };
  terminal = "${_ vars.alacritty-custom}";
}
