{ config, lib, pkgs, isInstall, isWorkstation, notVM, ... }:
let
  inherit (lib) mkDefault mkOption mkIf mkMerge optionals mkOverride;
  inherit (lib.types) bool nullOr enum str;
  cfg = config.system.boot;

  # Simplified disk detection: extract base device name
  rootDevice = config.fileSystems."/".device or null;
  autoBootDisk =
    if rootDevice != null then
      let
        devName = lib.last (lib.splitString "/" rootDevice);
        # Match and remove partition suffix (handles nvme0n1p1, sda1, mmcblk0p1)
        match = builtins.match "^(.*?)(p?[0-9]+)$" devName;
      in
      if match != null then "/dev/${builtins.elemAt match 0}" else rootDevice
    else null;

  # Determine boot device with fallback chain
  bootDevice =
    if cfg.bootType == "efi" || cfg.bootType == "hybrid-legacy"
    then "nodev"
    else if cfg.device != null
    then cfg.device
    else if autoBootDisk != null
    then autoBootDisk
    else if notVM
    then "/dev/sda"
    else "/dev/vda";
in
{
  options = {
    system.boot = {
      enable = mkOption {
        default = isInstall;
        type = bool;
        description = "Enable`s boot for installation.";
      };
      bootType = mkOption {
        type = nullOr (enum [ "efi" "legacy" "hybrid-legacy" null ]);
        default = null;
        description = "Default's boot option.";
      };
      device = mkOption {
        type = nullOr (str);
        default = null;
        description = "Device for GRUB loader (e.g., /dev/sda, /dev/vda, /dev/nvme0n1).";
      };
      bootManager = mkOption {
        type = nullOr (enum [ "grub" "systemd-boot" "raspberry" null ]);
        default = null;
        description = "Select the Default boot Manager.";
      };
      isDualBoot = mkOption {
        type = bool;
        default = false;
        description = "Enable's dualboot options.";
      };
      plymouth = mkOption {
        type = bool;
        default = false;
        description = "Enable's plymouth.";
      };
      silentBoot = mkOption {
        type = bool;
        default = false;
        description = "Whether or not to enable silent boot.";
      };
      secureBoot = mkOption {
        type = bool;
        default = false;
        description = "Whether or not to enable secure boot.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [ fwupd ]
        ++ optionals (cfg.bootType == "efi" || cfg.bootType == "hybrid-legacy") [
        efibootmgr
        efitools
        efivar
      ]
        ++ optionals cfg.secureBoot [ sbctl ]
        ++ optionals cfg.isDualBoot [ os-prober ];
    };

    boot = {
      consoleLogLevel = 0;

      initrd = {
        verbose = mkIf cfg.silentBoot false;
        systemd = {
          enable = if (cfg.bootType == "efi" || cfg.bootType == "hybrid=legacy") then true else false;
          mounts = mkIf cfg.plymouth [ "/sys/firmware/efi/efivars" ]; # For Plymouth in initrd
        };
      };

      extraModprobeConfig = mkIf (cfg.plymouth) ''
        blacklist iTCO_wdt
        blacklist iTCO_vendor_support
        blacklist sp5100_tco
      '';

      kernelPackages = mkOverride 1250 pkgs.unstable.linuxPackages_latest;

      kernel = {
        sysctl = mkMerge [
          (mkIf (cfg.silentBoot) {
            "kernel.printk" = "3 3 3 3"; # "4 4 1 7";
            "kernel.ftrace_enabled" = false; # Disable ftrace debugging
            "kernel.nmi_watchdog" = 0; # Disable NMI watchdog
          })
          (mkIf (cfg.bootManager == "raspberry") {
            "vm.dirty_background_ratio" = 5;
            "vm.dirty_ratio" = 80;
          })
        ];
      };

      kernelParams = [
        # Enable cgroups_v2
        "cgroup_no_v1=all"
        "systemd.unified_cgroup_hierarchy=yes"
      ] ++ optionals (cfg.plymouth) [
        "quiet"
        "splash"
        "fbcon=nodefer"
        "nowatchdog" # Disable watchdog
        "nmi_watchdog=0" # Disable watchdog
      ]
      ++ optionals (cfg.silentBoot) [
        "quiet" # tell the kernel to not be verbose
        "loglevel=3" # 1: system is unusable | 3: error condition | 7: very verbose
        "udev.log_level=3" # udev log message level
        "rd.udev.log_level=3" # lower the udev log level to show only errors or worse
        "systemd.show_status=auto" # disable systemd status messages
        "rd.systemd.show_status=auto" # rd prefix means systemd-udev will be used instead of initrd
        "vt.global_cursor_default=0" # disable the cursor in vt to get a black screen during intermissions
        "page_alloc.shuffle=1" # reduces the predictability of page allocations
        "rootflags=noatime" # ignore access time (atime) updates on files
      ]
      ++ optionals (cfg.bootManager == "raspberry") [ "cma=32M" ]
      ;

      lanzaboote = mkIf (cfg.secureBoot) {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };

      loader = {
        generic-extlinux-compatible.enable = mkIf (cfg.bootManager == "raspberry") true;

        efi = mkIf (cfg.bootType == "efi" || cfg.bootType == "hybrid-legacy") {
          canTouchEfiVariables = if (cfg.bootType == "efi" && config.boot.loader.grub.enable == false) then true else false;
          efiSysMountPoint = mkDefault "/boot";
        };

        generationsDir.copyKernels = mkIf (cfg.bootType == "efi") true;

        grub = mkIf (cfg.bootManager == "grub") {
          enable = mkIf (cfg.bootManager == "grub" && cfg.bootManager != "raspberry") true;
          efiSupport = if (cfg.bootType == "efi" || cfg.bootType == "hybrid-legacy") then true else false;
          efiInstallAsRemovable = if (cfg.bootType != "legacy") then true else false;
          default = "saved";
          device = bootDevice;
          fsIdentifier = "provided";
          gfxmodeEfi = "auto";
          fontSize = 20;
          configurationLimit = 8;
          # splashImage = ./backgrounds/grub-nixos-3.png;
          # splashMode = "stretch";
          extraEntries = ''
            menuentry "Reboot" { reboot }
            menuentry "Poweroff" { halt }
          '';
          useOSProber = if (cfg.isDualBoot == true) then true else false;
        };

        systemd-boot = mkIf (cfg.bootManager == "systemd-boot") {
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
        theme = "lone";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override { selected_themes = [ theme ]; })
        ];
      };

      tmp = {
        useTmpfs = true;
        tmpfsSize = "30%";
        cleanOnBoot = mkDefault (!config.boot.tmp.useTmpfs);
      };
    };

    systemd = {
      watchdog.rebootTime = mkIf (cfg.plymouth) "0";
    };

    # persistence.directories = mkIf persistence == true; [
    #   "/etc/secureboot"
    # ];
  };
}
