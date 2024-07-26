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
      tmp.cleanOnBoot = true;
      loader = {
        grub = {
          enable = true;
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
