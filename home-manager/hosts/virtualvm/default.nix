{ pkgs, lib, ... }: {
  programs.fish.enable = true;
  apps = {
    console.ssh.enable = true;
    graphical = {
      terminal.alacritty.enable = true;
      editor.vscode.enable = true;
      file-manager.spacefm.enable = true;
    };
  };
}
