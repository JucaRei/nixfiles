{ lib, pkgs, config, ... }:
with lib.hm.gvariant;
{
  imports = [
    ../_mixins/non-nixos
    ../_mixins/console/yt-dlp.nix
  ];

  config = {
    services = {
      nonNixOs.enable = true;
      yt-dlp-custom.enable = true;
    };

    home = {
      packages = with pkgs;[
        nix-whereis
      ];
      file = {
        ".face" = {
          # source = ./face.jpg;
          source = "${pkgs.juca-avatar}/share/faces/juca.jpg";
        };
      };
    };
  };
}

# sudo --preserve-env=PATH env application
