{ lib, pkgs, config, ... }:
let
  cfg = config.boot.mode.systemd-boot;
in
{
  options.boot.mode.systemd-boot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable boot for bios legacy mode.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      systemd-boot = {
        memtest86.enable = true;
        consoleMode = "max";
        configurationLimit = 5;
        editor = false;
        graceful = true;
      };
      timeout = 7;
    };
  };
}
