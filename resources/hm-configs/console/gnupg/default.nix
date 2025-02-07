{ config, pkgs, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs = {
    gpg = {
      enable = true;
      settings = { };
      homedir = "${config.xdg.dataHome}/gnupg";
      mutableTrust = true;
      mutableKeys = true;
    };
  };
  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 3600;
      pinentryPackage = mkDefault pkgs.pinentry-curses;
      enableSshSupport = true;
      enableExtraSocket = true;
    };
  };
}
