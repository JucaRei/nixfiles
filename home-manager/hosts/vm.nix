{ pkgs, ... }: {
  imports = [
    # ../_mixins/apps/text-editor/vscodium.nix
    # ../_mixins/apps/text-editor/vscode.nix
    # ../_mixins/apps/text-editor/sublime.nix
    ../_mixins/apps/video/mpv.nix
    ../_mixins/apps/text-editor/vscode.nix
    # ../_mixins/apps/text-editor/vscode-remote
    # ../_mixins/apps/social-media/discord.nix
    # ../_mixins/console/neovim.nix
    # ../_mixins/apps/browser/brave.nix
    ../_mixins/apps/browser/firefox.nix
    # ../_mixins/apps/terminal/alacritty.nix
  ];

  config = {
  # services.vscode-server.enable = true;
  home.packages = with pkgs; [
    # thorium
    clonegit
    # deezer-gui
    advcp
    deepin.deepin-icon-theme
    # emacs
  ];
  };
}
