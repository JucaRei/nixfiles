{ pkgs, ... }: {
  imports = [
    # ../_mixins/apps/music/rhythmbox.nix
    ../_mixins/apps/text-editor/vscode.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    ../_mixins/apps/terminal/alacritty.nix
    ../_mixins/apps/browser/firefox.nix
    ../_mixins/apps/video/mpv
    # ../_mixins/apps/tools/zathura.nix
    # ../_mixins/desktop/bspwm/themes/default
    # ../_mixins/apps/browser/opera.nix
  ];
  home = {
    packages = with pkgs;
      [
        # thorium 
      ];
    # shellAliases = {
    # sudo = "doas";
    # };
  };
}
