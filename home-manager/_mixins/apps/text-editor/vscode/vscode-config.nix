{ username, pkgs, config, ... }:

{
  home = {
    # packages = pkgs.unstable.vscode-fhs;
    file.".config/Code/User/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../../config/vscode/settings.json;
    };
    packages = with pkgs; [
      nil
      nixpkgs-fmt

      (nerdfonts.override {
        fonts = [
          "UbuntuMono"
          "JetBrainsMono"
          # "Hack"
          # "DroidSansMono"
        ];
      })
    ];
  };
}
