{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) nullOr enum;
in
{
  imports = [
    ./x11
    ./wayland
  ];

  options = {
    programs.graphical.desktop.backend = mkOption {
      type = nullOr (enum [ "x11" "wayland" ]);
      default = null;
      description = "Default backend for the system";
    };
  };
}
