{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) enum;
in
{
  imports = [
    ./x11
    ./wayland
  ];

  options = {
    desktop.backend = mkOption {
      type = enum [ "x11" "wayland" ];
      default = "x11";
      description = "Default backend for the system";
    };
  };
}
