{ config, pkgs, inputs, ... }: {
  imports = [
    # Import the vscode-server home-manager module from flake input
    "${inputs.vscode-server}/modules/vscode-server/home.nix"
  ];
  config = {
    # Enable the service
    services.vscode-server = {
      enable = true;
      # enableFHS = true;
    };

    apps = {
      console.ssh.enable = true;
      graphical = {
        # terminal.alacritty.enable = true;
        editor.vscode.enable = true;
      };
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
  };
}
