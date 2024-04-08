{ lib, pkgs, config, ... }:
with lib.hm.gvariant;
let
  font-search = pkgs.writeShellScriptBin "font-search" ''
    fc-list \
        | grep -ioE ": [^:]*$1[^:]+:" \
        | sed -E 's/(^: |:)//g' \
        | tr , \\n \
        | sort \
        | uniq
  '';
in
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
        font-search
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
