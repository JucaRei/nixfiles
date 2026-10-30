{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  config = {
    time.timeZone = mkDefault "America/Sao_Paulo";
    services.openssh.enable = mkDefault true;
  };
}
