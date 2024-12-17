{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs ; [
      cloneit
      typora
      unstable.obsidian
      deluge-gtk
      nil
      nixpkgs-fmt
      unstable.mpv
    ];

    console = {
      lsd.enable = true;
    };

    desktop.apps = {
      editors.vscode = {
        enable = true;
      };
    };
  };
}
