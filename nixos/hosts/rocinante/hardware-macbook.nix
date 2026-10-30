{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkIf;
  isX11 = (config.desktop.display-servers.backend == "x11") || config.services.xserver.enable;
in
{
  config = {
    # Permitir broadcom-sta apenas no host rocinante (hardware específico)
    nixpkgs.config.permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-63-7.1.9"
      "broadcom-sta-6.30.223.271-63-7.2.9"
      "broadcom-sta-6.30.223.271-63-7.2.11"
    ];
    nixpkgs.config.allowInsecurePredicate =
      pkg:
      lib.hasPrefix "broadcom-sta" (lib.getName pkg)
      || lib.strings.hasInfix "broadcom-sta" (lib.getName pkg);

    # --- Hardware & CPU (MacBook Pro 4,1 - Penryn Core 2 Duo) ---
    hardware = {
      cpu = {
        enable = true;
        cpuVendor = "intel";
        enableKvm = true;
        improveTCP = true;
      };

      graphics.cards = {
        enable = true;
        acceleration = true;
        gpu = null; # Padrão: driver open-source nouveau + Mesa nativa
      };

      # Firmware redistribuível (essencial para Wi-Fi Broadcom e Microcode Intel)
      enableRedistributableFirmware = true;

      # Domínio regulatório Brasil
      wirelessRegulatoryDatabase = true;
    };

    # --- Boot & GRUB BIOS/CSM (i386-pc obrigatório para a VBIOS da NVIDIA GeForce 8600M GT) ---
    system.boot = {
      enable = true;
      bootType = "legacy";
      bootManager = "grub";
      device = "/dev/sda";
      plymouth = true;
      silentBoot = true;
    };

    boot = {
      # Kernel padrão: Linux Zen do unstable (otimizado para agilidade de desktop em CPUs dual-core) + Nouveau
      kernelPackages = pkgs.unstable.linuxPackages_zen;

      initrd = {
        systemd.enable = false; # Evita falhas de montagem do /sysroot em hardware legado Intel ICH8-M
        availableKernelModules = [
          "ahci"
          "ata_piix"
          "pata_acpi"
          "ata_generic"
          "uhci_hcd"
          "ehci_pci"
          "firewire_ohci"
          "usb_storage"
          "usbhid"
          "sd_mod"
          "sr_mod"
          "applesmc"
          "btrfs"
          "simpledrm"
          "vesafb"
        ];
        kernelModules = [
          "applesmc"
          "hid_apple"
          "nouveau"
        ];
      };

      # Módulos carregados para o hardware do MacBook Pro 4,1
      kernelModules = [
        "applesmc"
        "hid_apple"
        "coretemp"
      ];

      # Teclado Apple: fnmode=1 (teclas multimídia/brilho nativas), swap_opt_cmd=0 (Command = Super, Option = Alt)
      extraModprobeConfig = ''
        options hid_apple fnmode=1 swap_opt_cmd=0
      '';

      # Blacklist dos módulos open-source que conflitam com o broadcom-sta (wl)
      blacklistedKernelModules = [
        "b43"
        "b43legacy"
        "bcma"
        "brcmsmac"
        "brcmfmac"
        "ssb"
      ];

      # Driver Broadcom STA para chip BCM43xx
      extraModulePackages = [
        config.boot.kernelPackages.broadcom_sta
      ];

      # Parâmetros de kernel para estabilidade térmica, GPU Nouveau e economia de energia
      kernelParams = [
        "pcie_aspm=force"
        "zswap.enabled=0"
        "mitigations=off"
        "nowatchdog"
        "nouveau.modeset=1"
        "transparent_hugepage=madvise"
        "elevator=bfq"
      ];

      # Tuning avançado de Memória Virtual para ZRAM + 6GB RAM (Canal Assimétrico)
      kernel.sysctl = {
        "vm.swappiness" = 180;
        "vm.vfs_cache_pressure" = 50;
        "vm.page-cluster" = 0;
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_ratio" = 15;
        "vm.dirty_writeback_centisecs" = 1500;
      };
    };

    zramSwap = {
      enable = true;
      algorithm = "lz4";
      memoryPercent = 75;
      priority = 100;
    };

    services = {
      # Controle térmico agressivo das ventoinhas do MacBook Pro (máximo acima de 60°C)
      mbpfan = {
        enable = true;
        settings.general = {
          min_fan1_speed = 2000;
          max_fan1_speed = 6000;
          min_fan2_speed = 2000;
          max_fan2_speed = 6000;
          low_temp = 45;
          high_temp = 55;
          max_temp = 60;
          polling_interval = 1;
        };
      };

      # Gestão de energia e temperatura (TLP com governors otimizados para Core 2 Duo)
      tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          SATA_LINKPWR_ON_AC = "med_power_with_dipm";
          SATA_LINKPWR_ON_BAT = "min_power";
          SCHED_POWERSAVE_ON_BAT = 1;
        };
      };

      thermald.enable = false;

      # Regras UDEV: Permissões de controle de brilho da tela e iluminação do teclado
      udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.uutils-coreutils-noprefix}/bin/chmod a+w /sys/class/backlight/%k/brightness"
        ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.uutils-coreutils-noprefix}/bin/chmod a+w /sys/class/leds/%k/brightness"
      '';

      xserver = mkIf isX11 {
        # Resolução nativa da tela WUXGA (MacBook Pro 17" - 1920x1200 @ 60Hz)
        resolutions = [
          {
            x = 1920;
            y = 1200;
          }
        ];
        dpi = 133;

        # Teclado Apple US International no X11 (dead keys para acentos PT-BR)
        xkb = {
          layout = "us";
          variant = "intl";
          options = "terminate:ctrl_alt_bksp";
        };
      };
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = mkDefault "nouveau";
      VDPAU_DRIVER = mkDefault "nouveau";
    };
  };
}
