{ config, pkgs, ... }: {
  imports = [ ../../_mixins/services/podman ];
  config = {
    features.nonNixOs = {
      enable = true;
    };
    console.yt-dlp-custom = {
      enable = true;
    };

    home = {
      packages = with pkgs; [
      ];
    };
  };
}
