{ lib, config, ... }:
with lib;
let
  cfg = config.boot.mode.systemd-efi;
in
{
  options.boot.mode.systemd-efi = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable boot for efi, with systemd.
      '';
    };
  };
  config = mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = true;
      loader = {
        efi = {
          canTouchEfiVariables = false;
          # efiSysMountPoint = "/boot";
        };
        systemd-boot = {
          enable = true;
          editor = true;
          configurationLimit = 5;
          graceful = true;
          #consoleMode = "max";
          memtest86.enable = true;
          # extraEntries = ''
          #   menuentry "Reboot" {
          #     reboot
          #   }
          #   menuentry "Poweroff" {
          #     halt
          #   }
          # '';
        };
        timeout = 5;
      };
    };
  };
}
