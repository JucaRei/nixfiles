{ pkgs, ... }: {
  imports = [
    # Import the vscode-server home-manager module
    "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];

  # Enable the service
  services.vscode-server = {
    enable = true;
    enableFHS = true;
  };

  # Optional: Enable an FHS environment for better extension compatibility

  # home.packages = [ pkgs.vscode ];

  # programs.vscode = {
  #   enable = true;
  #   extensions = with pkgs.vscode-extensions; [
  #     ms-vscode-remote.remote-ssh
  #     ms-vscode-remote.remote-containers
  #   ];
  # };
}
