{ config, pkgs, lib, ... }:
with lib.hm.gvariant; {
  imports = [
    ./gtk.nix
  ];
}
