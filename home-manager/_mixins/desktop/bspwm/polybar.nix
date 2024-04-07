{ pkgs, config, lib, ... }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
in
{
  enable = true;
  package = nixgl pkgs.unstable.polybarFull;
  settings =
    let
      ### Colors
      # ;; Dark Add FC at the beginning #FC1E1F29 for 99 transparency
      bg = "#2f354b";
      bg-alt = "#BF1D1F28";
      fg = "#FDFDFD";

      trans = "#00000000";
      white = "#FFFFFF";
      black = "#000000";

      # ;; Colors

      red = "#F37F97";
      pink = "#EC407A";
      purple = "#C574DD";
      blue = "#8897F4";
      cyan = "#79E6F3";
      teal = "#00B19F";
      green = "#5ADECD";
      lime = "#B9C244";
      yellow = "#F2A272";
      amber = "#FBC02D";
      orange = "#E57C46";
      brown = "#AC8476";
      grey = "#8C8C8C";
      indigo = "#6C77BB";
      blue-gray = "#6D8895";
    in
    {
      ##############
      ### System ###
      ##############
      "system" = {
        adapter = "AC";
        battery = "BAT1";
        graphics_card = "intelgpu";
        network_interface = "wlan0";
      };

      ##############
      ### Config ###
      ##############
      "global/wm" = {
        margin-bottom = 0;
        margin-top = 0;
      };

      "bar/pam1" = {
        monitor = "";
        monitor-fallback = "";
        monitor-strict = false;

        override-redirect = false;
        fixed-center = true;

        width = "2.5%";
        height = 40;

        offset-x = "2%";
        offset-y = 10;

        background = "${bg-alt}";
        foreground = "${fg}";

        radius = 6;

        line-size = 2;
        line-color = "${blue}";

        padding = 0;

        module-margin-left = 0;
        module-margin-right = 0;

        font-0 = "${pkgs.iosevka}/";
      };
    };
}
