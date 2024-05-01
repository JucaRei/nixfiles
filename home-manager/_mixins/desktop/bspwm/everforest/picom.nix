{ config, pkgs, ... }:
let
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
  nixgl = import ../../../../../lib/nixGL.nix { inherit config pkgs; };
in
{
  services = {
    picom = {
      enable = true;
      package = if (isGeneric) then (nixgl pkgs.picom) else pkgs.picom;
      backend = "xrender"; # "glx";
      shadow = true;
      shadowExclude = [
        "_GTK_FRAME_EXTENTS@:c"
      ];
      fade = true;
      fadeDelta = 5;
      inactiveOpacity = 0.95;
      settings = {
        blur = {
          method = "dual_kawase";
          size = 24;
          strenght = 12;
          deviation = 5.0;
          backround-exclude = [
            "window_type = 'dock'"
            "window_type = 'conky'"
            "window_type = 'desktop'"
            "class_g = 'slop'"
            "_GTK_FRAME_EXTENTS@:c"
          ];
        };
        corner-radius = 10;
        rounded-corners-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
		  "window_type = 'conky'"
        ];
        use-ewmh-active-win = true;
        unredir-if-possible = false; # true;
      };
      vSync = false;
      extraArgs = [
        "--legacy-backends"
        # "--use-damage"
      ];
    };
  };
}
