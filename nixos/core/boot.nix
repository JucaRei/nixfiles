{ lib
, notVM
, isInstall
, config
, pkgs
, ...
}:

############################
### Default Boot Options ###
############################
let
  inherit (lib) mkIf mkOverride types mkDefault mkOption;
  cfg = config.sys.boot;

  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };

  mkOpt' = type: default: mkOpt type default null;

  mkBoolOpt = mkOpt types.bool;

  mkBoolOpt' = mkOpt' types.bool;

in
{
  options.sys.boot = {
    enable = mkBoolOpt false "Whether or not to enable booting.";
    efi = mkBoolOpt false "Whether or not to enable EFI for booting.";
    bios = mkBoolOpt false "Whether or not to enable Bios Legacy for booting.";
    grub = mkBoolOpt false "Whether or not to enable Grub for booting.";
    systemd-boot = mkBoolOpt false "Whether or not to enable Systemd for booting.";
    isDualBoot = mkBoolOpt false "Whether or not to enable for dual booting.";
    plymouth = mkBoolOpt false "Whether or not to enable plymouth boot splash.";
    # secureBoot = mkBoolOpt false "Whether or not to enable secure boot.";
    silentBoot = mkBoolOpt false "Whether or not to enable silent boot.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [ fwupd ]
      ++ lib.optionals cfg.efi [
        efibootmgr
        efitools
        efivar
      ]
      # ++ lib.optionals cfg.secureBoot [ sbctl ]
      ++ lib.optionals cfg.isDualBoot [ os-prober ];

    boot = {
      initrd = {
        verbose = false;
        systemd = {
          enable = true;
        };
      };
      kernelParams =
        lib.optionals cfg.plymouth [ "quiet" ]
        ++ lib.optionals cfg.silentBoot [
          # tell the kernel to not be verbose
          "quiet"

          # kernel log message level
          "loglevel=3" # 1: system is unusable | 3: error condition | 7: very verbose

          # udev log message level
          "udev.log_level=3"

          # lower the udev log level to show only errors or worse
          "rd.udev.log_level=3"

          # disable systemd status messages
          # rd prefix means systemd-udev will be used instead of initrd
          "systemd.show_status=auto"
          "rd.systemd.show_status=auto"

          # disable the cursor in vt to get a black screen during intermissions
          "vt.global_cursor_default=0"
        ];

      # lanzaboote = mkIf cfg.secureBoot {
      #   enable = true;
      #   pkiBundle = "/etc/secureboot";
      # };

      loader = {
        efi = mkIf cfg.efi {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
        generationsDir.copyKernels = cfg.efi;


        grub = mkIf cfg.grub {
          enable = true;
          # efiSupport = lib.optionals cfg.efi;
          default = "saved";
          # forceInstall = true;
          devices = if cfg.efi then [ "nodev" ] else [ "/dev/sda" ];
          # devices = [ "nodev" ];
          fsIdentifier = "provided";
          gfxmodeEfi = "auto";
          fontSize = 20;
          configurationLimit = mkDefault 10;
          extraEntries = ''
            menuentry "Reboot" {
              reboot
            }
            menuentry "Poweroff" {
              halt
            }
          '';
        };

        # generationsDir.copyKernels = true;

        systemd-boot = mkIf cfg.systemd-boot {
          enable = true;
          configurationLimit = 10;
          editor = false;
        };
      };

      plymouth = rec {
        enable = cfg.plymouth;
        theme = "deus_ex";
        themePackages = with pkgs; [
          (
            # pkgs.catppuccin-plymouth
            adi1090x-plymouth-themes.override { selected_themes = [ theme ]; }
          )
        ];
      };

      tmp = mkDefault {
        useTmpfs = true;
        cleanOnBoot = true;
        tmpfsSize = "25%";
      };

      # kernelParams = [
      #   "vt.global_cursor_default=0" # stop cursor blinking
      #   "vt.cur_default=0x700010" # static white block
      #   "udev.log_priority=3"
      # ];
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
  };
}
