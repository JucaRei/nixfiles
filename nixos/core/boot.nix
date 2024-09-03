{ lib, notVM, isInstall, config, ... }:

with lib;
############################
### Default Boot Options ###
############################
{
  boot = mkDefault {
    initrd = {
      verbose = false;
      systemd = {
        enable = true;
      };
    };
    consoleLogLevel = 3; # Default is 4;
    tmp = {
      cleanOnBoot = true; # Delete all files in /tmp during boot.
      useTmpfs = true; # Mount a tmpfs on /tmp during boot.
      tmpfsSize = "25%"; # Size
    };
    kernelModules = mkIf (notVM) [ "vhost_vsock" ];

    kernelParams = [
      "vt.global_cursor_default=0" # stop cursor blinking
      "vt.cur_default=0x700010" # static white block
      "udev.log_priority=3"
    ];
    supportedFilesystems = [
      "ext4"
      "exfat"
      "ntfs"
      "btrfs"
      # "bcachefs"
    ];

    kernelPackages =
      #        default = 1000
      #   this default = 1250
      # option default = 1500
      mkOverride 1500 pkgs.linuxPackages_latest;
  };
}
