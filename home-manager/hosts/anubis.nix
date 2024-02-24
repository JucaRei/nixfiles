{ pkgs, ... }: {
  imports = [
    # ../_mixins/apps/music/rhythmbox.nix
    ../_mixins/apps/text-editor/vscode.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    ../_mixins/apps/terminal/alacritty.nix
    ../_mixins/apps/browser/firefox/librewolf.nix
    ../_mixins/apps/video/mpv.nix
    ../_mixins/non-nixos
    # ../_mixins/apps/tools/zathura.nix
    # ../_mixins/desktop/bspwm/themes/default
    # ../_mixins/apps/browser/opera.nix
  ];
}
