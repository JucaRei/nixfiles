{ pkgs, ... }: {
  imports = [
    # ../_mixins/apps/music/rhythmbox.nix
    ../_mixins/apps/text-editor/vscode.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    ../_mixins/apps/terminal/alacritty.nix
    ../_mixins/apps/browser/firefox.nix
    ../_mixins/apps/video/mpv
  ];
  home = {
    packages = with pkgs; [
    ];
  };
}
