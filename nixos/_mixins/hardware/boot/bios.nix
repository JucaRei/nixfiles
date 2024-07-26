{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.boot.mode.bios;
in
{
  options.boot.mode.bios = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable boot for bios legacy mode.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot = {
      initrd = {
        ## SSH on initramfs.
        #network = {
        #  enable = true;
        #  ssh.enable = true;
        #};
      };
      tmp.cleanOnBoot = true;
      loader = {
        grub = {
          enable = true;
          #version = 2;
          efiSupport = false;
          device = lib.mkDefault "/dev/sda"; # MBR/BIOS
          fsIdentifier = "provided";

          backgroundColor = "#21202D";
          configurationLimit = 6;

          extraConfig = ''
            set menu_color_normal=light-blue/black
            set menu_color_highlight=black/light-blue
          '';
          #splashMode = lib.mkDefault "normal";
          #splashImage = lib.mkDefault null;
          configurationName = "Nixos Configuration";
          extraEntries = ''
            menuentry "Reboot" {
              reboot
            }
            menuentry "Poweroff" {
              halt
            }
          '';
        };
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = false;
      };
    };
  };
}
