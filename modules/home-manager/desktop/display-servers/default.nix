{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) nullOr enum;
in
{
  imports = [
    ./x11
    ./wayland
  ];

  options = {
    desktop.display-servers.backend = mkOption {
      type = nullOr (enum [ "x11" "wayland" ]);
      default = null;
      description = "Default backend for the system";
    };
  };
}
