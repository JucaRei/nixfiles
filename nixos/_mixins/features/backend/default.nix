{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./x11
    ./wayland
  ];

  options.features.graphics = {
    backend = mkOption {
      type = types.enum [ "x11" "wayland" null ];
      default = null;
      description = "Default backend for the system";
    };
  };
}
