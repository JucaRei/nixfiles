{ writeShellApplication, pkgs, ... }:
writeShellApplication {
  name = "wayland-screenshot";
  runtimeInputs = [ pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.swayimg ];
  text = ''
    # ideas stolen from https://github.com/emersion/slurp/issues/104#issuecomment-1381110649

    grim - | swayimg --background none --scale real --no-sway --fullscreen --layer - &
    # shellcheck disable=SC2064
    trap "kill $!" EXIT
    grim -t png -g "$(slurp)" - | wl-copy -t image/png
  '';
}
