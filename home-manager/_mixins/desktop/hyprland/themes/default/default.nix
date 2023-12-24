{ pkgs, lib, config, hostname, ... }:
let
  scripts.wl-screenshot = {
    runtimeInputs = [ pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.swayimg ];
    text = ''
      # ideas stolen from https://github.com/emersion/slurp/issues/104#issuecomment-1381110649

      grim - | swayimg --background none --scale real --no-sway --fullscreen --layer - &
      # shellcheck disable=SC2064
      trap "kill $!" EXIT
      grim -t png -g "$(slurp)" - | wl-copy -t image/png
    '';

    layout = if hostname == "nitro" then "br" else "us";
    variant = if hostname == "nitro" then "abnt2" else "mac";
    model = if hostname == "nitro" then "pc105" else "pc104";
  };
in
{
  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        systemd.enable = if hostname == "nitro" then true else false;
        extraConfig = ''
          monitor = eDP-1, highrr, 0x0, 1
          monitor = HDMI-A-1, 1920x1080, -1920x0, 1

          env = XCURSOR_SIZE,24
          env = WLR_DRM_NO_ATOMIC,1

          input {
            kb_layout = $\{layout}
            kb_variant = $\{variant}
            kb_model = $\{model}
            kb_options =
            kb_rules =

            follow_mouse = 2 #1

            touchpad {
              natural_scroll = true
              clickfinger_behavior = true
              tap-and-drag = true
            }
          }
        '';
      };
    };
  };
}
