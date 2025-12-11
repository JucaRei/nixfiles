{ config, lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) enum;
in
{
  imports = [
    ./x11
    ./wayland
  ];
  options.desktop.backend = mkOption {
    type = enum [ "x11" "wayland" ];
    default = "x11";
    description = "Whether to use X11 or Wayland backend.";
  };
}
