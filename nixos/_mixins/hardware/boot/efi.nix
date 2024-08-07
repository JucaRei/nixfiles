{ lib, pkgs, hostname, config, ... }:
with lib;
let
  cfg = config.boot.mode.efi;
  isNitro = if (hostname == "nitro") then true else false;
in
{
  options.boot.mode.efi = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable boot for efi bios mode.
      '';
    };
  };
  config = mkIf cfg.enable {
    boot = with lib;{
      tmp = {
        #useTmpfs = true;
        cleanOnBoot = true;
      };
      loader = {
        efi = {
          # canTouchEfiVariables = if hostname == "air" then false else true;
          canTouchEfiVariables = true;
          # efiSysMountPoint = mkDefault "/boot/efi";
          efiSysMountPoint = "/boot";
        };
        grub = {
          useOSProber = isNitro;
          enable = !config.boot.isContainer;
          default = mkIf (isNitro) "saved";
          # devices = [ "nodev" ]; # "nodev" for efi only
          device = "nodev"; # "nodev" for efi only
          efiSupport = true;
          # efiInstallAsRemovable = true; #  Don't depend on NVRAM state
          configurationLimit = 5;
          forceInstall = true;
          #splashMode = "stretch";
          #theme = with pkgs; [ nixos-grub2-theme libsForQt5.breeze-grub ];

          ### For encrypted boot
          # enableCryptodisk = true;

          ## If tpm is activated
          # trustedBoot.systemHasTPM = "YES_TPM_is_activated"
          # trustedBoot.enable = true;

          ## If using zfs filesystem
          # zfsSupport = true;                        # enable zfs
          # copyKernels = true;

          # useOSProber = false;
          fsIdentifier = "provided";
          # fsIdentifier = "label";
          gfxmodeEfi = "auto";
          #gfxmodeEfi = "1366x788";
          fontSize = 20;
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
      };
    };

    environment = mkIf (isNitro) {
      systemPackages = with pkgs;[ os-prober ];
    };
  };
}
