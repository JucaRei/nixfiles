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
  };
}

# sudo --preserve-env=PATH env application
