{ lib, pkgs, isISO, ... }:
let
  inherit (lib) mkDefault;
in
{
  config = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = mkDefault true;
        PermitRootLogin = mkDefault (if isISO then "yes" else "no");
        Banner = "${pkgs.writeText "ssh-banner" (builtins.readFile ./ssh-banner.txt)}";
      };
      startWhenNeeded = true;
    };
  };
}
