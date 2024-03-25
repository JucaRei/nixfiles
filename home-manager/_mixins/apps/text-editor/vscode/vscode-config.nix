{ username, config ? args, ... }@args:

{
  home = {
    # packages = pkgs.unstable.vscode-fhs;
    file.".config/Code/User/settings.json" = {
      # source = ../../../config/vscode/settings.json;
      source = ../../../config/vscode/settings-test.nix args;
    };
  };
}
