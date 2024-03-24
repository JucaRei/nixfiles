{ pkgs, config, ... }:
let
  nixGL = import ../../lib/nixGL.nix { inherit config pkgs; };
  mpv-custom = import ../_mixins/apps/video/mpv.nix { inherit config pkgs; };
in
{
  imports = [
    # ../_mixins/apps/music/rhythmbox.nix
    # ../_mixins/apps/text-editor/vscode.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    # ../_mixins/apps/terminal/alacritty.nix
    # ../_mixins/apps/browser/firefox/librewolf.nix
    # ../_mixins/apps/video/mpv.nix
    ../_mixins/non-nixos
    # ../_mixins/apps/tools/zathura.nix
    # ../_mixins/desktop/bspwm/themes/default
    # ../_mixins/apps/browser/opera.nix
  ];
  config = {
    nix.settings = {
      extra-substituters = [ "https://anubis.cachix.org" ];
      extra-trusted-public-keys = [ "anubis.cachix.org-1:p6q0lqdZcE9UrkmFonRSlRPAPADFnZB1atSgp6tbF3U=" ];
    };

    home = {
      packages = with pkgs; [
        (nixGL mpv-custom)
      ];
    };
  };
}
