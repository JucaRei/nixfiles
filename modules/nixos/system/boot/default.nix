{ config, lib, pkgs, namespace, ... }:
let
  inherit (lib) mkIf mdDoc optionals mkDefault mkOverride mkMerge;
  inherit (lib.${namespace}) mkOpt mkBoolOpt;
  inherit (lib.types) nullOr path enum null;

  cfg = config.${namespace}.system.boot;

  notVM = config.system.build.vm != "kvm";
in
{
  options.${namespace}.system.boot = {
    enable = mkBoolOpt false (mdDoc "Whether or not to enable booting.");
    boottype = mkOpt (nullOr (enum [ "efi" "legacy" "hybrid-legacy" null ])) null (mdDoc "The boot type to use.");
    bootmanager = mkOpt (nullOr (enum [ "grub" "systemd-boot" "raspberry" null ])) null (mdDoc "The default bootmanager to use.");
    plymouth = mkBoolOpt false (mdDoc "Whether or not to enable plymouth boot splash.");
    device = mkOpt path null (mdDoc "The device to install the bootloader to.");
    isDualBoot = mkBoolOpt false (mdDoc "Whether or not to enable dual boot.");
    secureBoot = mkBoolOpt false (mdDoc "Whether or not to enable secure boot.");
    silentBoot = mkBoolOpt false (mdDoc "Whether or not to enable silent boot.");
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ fwupd ]
      ++
      optionals (cfg.boottype == "efi" || cfg.boottype == "hybrid-legacy") [
        efibootmgr
        efitools
        efivar
      ]
      ++ optionals cfg.secureBoot [ sbctl ]
      ++ optionals cfg.isDualBoot [ os-prober ];

    boot = {
      consoleLogLevel = 0;

      initrd = {
        verbose = if (cfg.silentBoot) then true else false;
        systemd = {
          enable = if (cfg.boottype == "efi" || cfg.boottype == "hybrid-legacy") then true else false;
          strip = mkDefault true; # Saves considerable space in initrd
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
        mkOverride 1250 pkgs.linuxPackages_latest.unstable;

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

      kernelModules = mkIf notVM [ "vhost_vsock" ];

      kernelParams = [
        # Enable cgroups_v2
        "cgroup_no_v1=all"
        "systemd.unified_cgroup_hierarchy=yes"
      ]
      ++ optionals cfg.plymouth [
        "quiet"
        "splash"
        "fbcon=nodefer"
        "nowatchdog" # Disable watchdog
        "nmi_watchdog=0" # Disable watchdog
      ]
      ++ optionals cfg.plymouth [ "quiet" ]
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
        pkiBundle = "/var/lib/sbctl";
      };

      loader = {
        generic-extlinux-compatible.enable = mkIf (cfg.bootmanager == "raspberry") true;

        efi = mkIf (cfg.boottype == "efi" || cfg.boottype == "hybrid-legacy") {
          canTouchEfiVariables = if (cfg.boottype == "efi" && cfg.bootmanager != true) then false else true;
          efiSysMountPoint = mkDefault "/boot";
        };
        generationsDir.copyKernels = mkIf cfg.boottype == "efi";

        systemd-boot = {
          enable = !cfg.secureBoot;
          configurationLimit = 20;
          editor = false;
        };
      };

      grub = mkIf (cfg.bootmanager == "grub") {
        enable = mkIf (cfg.bootmanager == "grub" && cfg.bootmanager != "raspberry") true;
        efiSupport = if (cfg.boottype == "efi" || cfg.boottype == "hybrid-legacy") then true else false;
        # theme = mkDefault pkgs.catppuccin-grub;
        efiInstallAsRemovable = if (cfg.boottype != "legacy") then true else false;
        default = "saved";
        device = if (cfg.boottype == "efi" && cfg.bootmanager == "grub" || cfg.boottype == "hybrid-legacy" && cfg.bootmanager == "grub") then "nodev" else "/dev/sda";
        fsIdentifier = "provided";
        gfxmodeEfi = "auto";
        fontSize = 20;
        configurationLimit = 10;
        # splashImage = ./backgrounds/grub-nixos-3.png;
        # splashMode = "stretch";
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
        useOSProber = if (cfg.isDualBoot == true) then true else false;
      };

      systemd-boot = mkIf (cfg.bootmanager == "systemd-boot") {
        enable = true;
        consoleMode = "max";
        configurationLimit = 10;
        editor = false;
        memtest86.enable = true;
      };
      timeout = 7;

      plymouth = rec {
        enable = cfg.plymouth;
        # catppuccin.enable = true;
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
        cleanOnBoot = mkDefault (!config.boot.tmp.useTmpfs);
        tmpfsSize = "50%";
      };
    };

    services.fwupd = {
      enable = true;
      daemonSettings.EspLocation = config.boot.loader.efi.efiSysMountPoint;
    };

    systemd.watchdog.rebootTime = mkIf (cfg.plymouth) "0";

    # persistence.directories = mkIf persistence == true; [
    #   "/etc/secureboot"
    # ];
  };
}
