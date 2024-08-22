{ pkgs, config, lib, ... }: {
  imports = [ ];
  config = {
    # Enable modules
    modules = {
      atuin.enable = true;
      htop.enable = true;
      eza.enable = false;
      lsd.enable = true;
      yt-dlp-custom.enable = true;
      wallpapers.enable = true;
      powerline-go.enable = true;
      # apps = {
      #   joplin.enable = true;
      # };
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
