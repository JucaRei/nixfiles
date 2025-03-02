{ config, pkgs, inputs, ... }: {
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

    # nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
