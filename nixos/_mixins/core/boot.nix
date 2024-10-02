{ lib, config, pkgs, isWorkstation, isInstall, notVM, inputs, ... }:

############################
### Default Boot Options ###
############################
let
  inherit (lib) mkIf mkOverride mkEnableOption types mkDefault mkOption listOf enum optionals mkMerge;
  cfg = config.core.boot;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  options.core.boot = {
    enable = mkEnableOption "Default booting type." //
      { default = false; };
    boottype = mkOption {
      type = types.nullOr (types.enum [ "efi" "legacy" null ]);
      default = null; # "efi";
      description = "Default boot option.";
    };
    device = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Device for GRUB boot loader.
      '';
    };
    bootmanager = mkOption {
      type = types.nullOr (types.enum [ "grub" "systemd-boot" "raspberry" null ]);
      default = null; # "grub";
      description = "Whether or not to enable EFI for booting.";
    };
    isDualBoot = mkEnableOption "Whether or not to enable for dual booting." // { default = false; };
    plymouth = mkEnableOption "Whether or not to enable plymouth boot splash." // {
      default = isWorkstation && isInstall;
    };
    silentBoot = mkEnableOption "Whether or not to enable silent boot." // { default = isWorkstation && isInstall; };
    secureBoot = mkEnableOption "Whether or not to enable secure boot." // { default = false; };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ fwupd ]
      ++ optionals (cfg.boottype == "efi") [
      efibootmgr
      efitools
      efivar
    ]
      ++ optionals cfg.secureBoot [ sbctl ]
      ++ optionals cfg.isDualBoot [ os-prober ];
    boot = {
      consoleLogLevel = 0;
      initrd = {
        verbose = mkIf cfg.silentBoot;
        systemd = {
          enable = if cfg.boottype == "efi" then true else false;
        };
      };

      # Disable watchdog
      extraModprobeConfig = mkIf cfg.plymouth ''
        blacklist iTCO_wdt
        blacklist iTCO_vendor_support
        blacklist sp5100_tco
      '';

      kernelPackages =
        #        default = 1000
        #   this default = 1250
        # option default = 1500
        mkOverride 1250 pkgs.linuxPackages_latest;

      kernelModules = mkIf (notVM) [ "vhost_vsock" ];

      kernel = {
        sysctl = mkMerge [
          (mkIf cfg.silentBoot
            {
              "kernel.printk" = "3 3 3 3"; # "4 4 1 7";

              # Hide kptrs even for processes with CAP_SYSLOG
              # also prevents printing kernel pointers
              "kernel.kptr_restrict" = 2;

              # Disable ftrace debugging
              "kernel.ftrace_enabled" = false;

              # Disable NMI watchdog
              "kernel.nmi_watchdog" = 0;
            })

          (mkIf (cfg.bootmanager == "raspberry")
            {
              "vm.dirty_background_ratio" = 5;
              "vm.dirty_ratio" = 80;
            })
        ];
      };

      kernelParams = [
        # Enable cgroups_v2
        "cgroup_no_v1=all"
        "systemd.unified_cgroup_hierarchy=yes"
      ] ++ optionals cfg.plymouth [
        "quiet"
        "splash"
        "fbcon=nodefer"
        "nowatchdog" # Disable watchdog
        "nmi_watchdog=0" # Disable watchdog
      ]
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

        # performance improvement for direct-mapped memory-side-cache utilization
        # reduces the predictability of page allocations
        "page_alloc.shuffle=1"

        #  ignore access time (atime) updates on files
        # except when they coincide with updates to the ctime or mtime
        "rootflags=noatime"

      ]
      ++ optionals (cfg.bootmanager == "raspberry") [
        "cma=32M"
      ];

      lanzaboote = mkIf cfg.secureBoot {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };

      loader = {
        generic-extlinux-compatible.enable = mkIf (cfg.bootmanager == "raspberry") true;

        efi = mkIf (cfg.boottype == "efi") {
          # canTouchEfiVariables = mkDefault true;
          efiSysMountPoint = mkDefault "/boot";
        };
        generationsDir.copyKernels = mkIf cfg.boottype == "efi";

        grub = mkIf (cfg.bootmanager == "grub") {
          enable = mkIf (cfg.bootmanager == "grub" && cfg.bootmanager != "raspberry") true;
          efiSupport = if cfg.boottype == "efi" then true else false;
          theme = mkDefault pkgs.catppuccin-grub;
          efiInstallAsRemovable = mkDefault true;
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
        theme = "lone"; # "spinner_alt"; # "deus_ex";
        themePackages = with pkgs; [
          (
            # pkgs.catppuccin-plymouth
            adi1090x-plymouth-themes.override { selected_themes = [ theme ]; }
          )
        ];
      };

      tmp = {
        useTmpfs = true;
        tmpfsSize = "30%";
        cleanOnBoot = mkDefault (!config.boot.tmp.useTmpfs);
      };
    };
    systemd.watchdog.rebootTime = mkIf (cfg.plymouth) "0";

    # persistence.directories = mkIf persistence == true; [
    #   "/etc/secureboot"
    # ];
  };
}
