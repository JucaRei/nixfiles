{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkDefault mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.tools.gnupg;
in
{
  options = {
    programs.terminal.tools.gnupg = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable GnuPG support.";
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
