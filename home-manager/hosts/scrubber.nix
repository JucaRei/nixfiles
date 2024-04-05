{ lib, ... }:
with lib.hm.gvariant;
{
  imports = [
    ../_mixins/non-nixos
  ];

  config = {
    services = {
      nonNixOs.enable = true;
    };

    home = {
      packages = with pkgs;[
        nix-whereis
      ];
    };
  };
}

# sudo --preserve-env=PATH env application
