{ lib, notVM, isInstall, config, pkgs, isWorkstation, ... }:

############################
### Default Boot Options ###
############################
let
  inherit (lib) mkIf mkOverride mkEnableOption types mkDefault mkOption listOf enum optionals;
  cfg = config.sys.boot;

  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };

  mkOpt' = type: default: mkOpt type default null;

  mkBoolOpt = mkOpt types.bool;

  mkBoolOpt' = mkOpt' types.bool;

in
{
  # options.sys.boot = {
  #   enable = mkBoolOpt false "Whether or not to enable booting.";
  #   efi = mkBoolOpt false "Whether or not to enable EFI for booting.";
  #   bios = mkBoolOpt false "Whether or not to enable Bios Legacy for booting.";
  #   grub = mkBoolOpt false "Whether or not to enable Grub for booting.";
  #   systemd-boot = mkBoolOpt false "Whether or not to enable Systemd for booting.";
  #   isDualBoot = mkBoolOpt false "Whether or not to enable for dual booting.";
  #   plymouth = mkBoolOpt false "Whether or not to enable plymouth boot splash.";
  #   # secureBoot = mkBoolOpt false "Whether or not to enable secure boot.";
  #   silentBoot = mkBoolOpt false "Whether or not to enable silent boot.";
  # };

  options.sys.boot = {
    enable = mkEnableOption "Default booting type." // { default = true; };

    boottype = mkOption {
      # type = types.listOf (types.enum [ "efi" "legacy" ]);
      type = types.nullOr (types.enum [ "efi" "legacy" ]);
      default = "efi"; # "efi";
      description = "Default boot option.";
    };
    bootmanager = mkOption {
      # type = types.listOf (types.enum [ "grub" "systemd-boot" ]);
      type = types.nullOr (types.enum [ "grub" "systemd-boot" ]);
      default = "grub"; # "systemd-boot";
      description = "Whether or not to enable EFI for booting.";
    };
    isDualBoot = mkEnableOption "Whether or not to enable for dual booting." // { default = false; };
    plymouth = mkEnableOption "Whether or not to enable plymouth boot splash." // {
      default = isWorkstation;
    };
    # secureBoot = mkEnableOption false "Whether or not to enable secure boot.";
    silentBoot = mkEnableOption "Whether or not to enable silent boot." // { default = isWorkstation; };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ fwupd ]
      ++ optionals (cfg.boottype == "efi") [
      efibootmgr
      efitools
      efivar
    ]
      # ++ optionals cfg.secureBoot [ sbctl ]
      ++ optionals cfg.isDualBoot [ os-prober ];

    boot = {
      consoleLogLevel = 0;
      initrd = {
        verbose = false;
        systemd = {
          enable = true;
        };
      };
      kernelParams = optionals cfg.plymouth [ "quiet" "splash" ]
        ++ optionals cfg.silentBoot [
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
        efi = mkIf (cfg.boottype == "efi") {
          canTouchEfiVariables = mkDefault true;
          efiSysMountPoint = mkDefault "/boot";
        };
        generationsDir.copyKernels = mkIf cfg.boottype == "efi";

        grub = mkIf (cfg.bootmanager == "grub") {
          enable = true;
          efiSupport = if cfg.boottype == "efi" then true else false;
          theme = mkDefault pkgs.catppuccin-grub;
          default = "saved";
          # devices = if cfg.boottype == "efi" then mkDefault [ "nodev" ] else mkDefault "/dev/sda";
          device = if cfg.boottype == "efi" then "nodev" else "/dev/sda";
          # device = if cfg.boottype == "efi" && cfg.bootmanager == "grub" then "nodev" else "/dev/sda";
          fsIdentifier = "provided";
          gfxmodeEfi = "auto";
          fontSize = 20;
          configurationLimit = 10;
          extraEntries = ''
            menuentry "Reboot" {
              reboot
            }
            menuentry "Poweroff" {
              halt
            }
          '';
        };

        systemd-boot = mkIf (cfg.bootmanager == "systemd-boot") {
          enable = true;
          consoleMode = "max";
          configurationLimit = 10;
          editor = false;
          memtest86.enable = true;
        };
        timeout = 7;
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
        tmpfsSize = "30%";
        cleanOnBoot = true;
      };
    };
  };
}
