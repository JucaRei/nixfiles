{ lib, notVM, isInstall, config, pkgs, ... }:

############################
### Default Boot Options ###
############################
let
  inherit (lib) mkIf mkOverride mkOpt types;
  cfg = config.sys.boot;
in
{
  # options.sys.boot = {
  #   enable = mkOpt types.bool isInstall "Whether or not to enable booting.";
  #   efi = mkOpt types.bool false "Whether or not to enable EFI for booting.";
  #   bios = mkOpt types.bool false "Whether or not to enable Bios Legacy for booting.";
  #   grub = mkOpt types.bool false "Whether or not to enable Grub for booting.";
  #   systemd-boot = mkOpt types.bool false "Whether or not to enable Systemd for booting.";
  #   isDualBoot = mkOpt types.bool false "Whether or not to enable for dual booting.";
  #   plymouth = mkOpt types.bool false "Whether or not to enable plymouth boot splash.";
  #   secureBoot = mkOpt types.bool false "Whether or not to enable secure boot.";
  #   silentBoot = mkOpt types.bool false "Whether or not to enable silent boot.";
  # };

  # config = mkIf cfg.enable {
  boot = {
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
  # };
}
