{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  config = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
        PermitRootLogin = mkDefault "yes";
        Banner = "${pkgs.writeText "ssh-banner" (builtins.readFile ./ssh-banner.txt)}";
      };
      startWhenNeeded = false;
    };
  };
}
