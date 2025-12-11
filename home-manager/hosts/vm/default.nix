{ pkgs, ... }: {
  home.packages = [ pkgs.vscode ];
  
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-containers
    ];
  };
}
