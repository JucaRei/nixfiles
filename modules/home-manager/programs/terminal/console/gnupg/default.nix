{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkDefault mkIf;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.console.gnupg;
in
{
  options = {
    programs.terminal.console.gnupg = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable GnuPG support.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs = {
      gpg = {
        enable = true;
        settings = { };
        homedir = "${config.xdg.dataHome}/.gnupg";
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
  };
}
