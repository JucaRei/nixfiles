{ username, config, ... }@args: {
  home = args {
    # packages = pkgs.unstable.vscode-fhs;
    file.".config/Code/User/settings.json" = {
      # source = ../../../config/vscode/settings.json;
      source = ../../../config/vscode/settings-test.nix;
    };
  };
}
