{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  config = {
    services.qemuGuest.enable = mkDefault true;
    services.spice-vdagentd.enable = mkDefault true;
  };
}
