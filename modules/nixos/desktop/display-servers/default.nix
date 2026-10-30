{ lib, ... }:
let
  inherit (lib.types) nullOr enum;
in
{
  imports = lib.my.importDir ./.;

  options = {
    desktop.display-servers.backend = lib.my.mkOpt (nullOr (enum [
      "x11"
      "wayland"
    ])) null "Default backend for the system";
  };
}
