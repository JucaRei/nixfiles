{ pkgs, config, lib, ... }: {
  imports = [
    (import ../../../modules/home-manager/linux/cli/fish {
      inherit config pkgs lib;
    }) # fish as default Shell
  ];
  config = {
    # Enable modules
    modules = {
      atuin.enable = true;
      htop.enable = true;
      eza.enable = false;
      lsd.enable = true;
    };
    home = {
      packages = with pkgs; [
        nix
        nil
        nixpkgs-fmt
        nixd
      ];
    };
  };
}
