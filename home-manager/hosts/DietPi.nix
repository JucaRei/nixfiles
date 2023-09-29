{ config, ... }: {
  imports = [
    ../_mixins/console/fish.nix
  ];
  targets.genericLinux.enable = true;
}
