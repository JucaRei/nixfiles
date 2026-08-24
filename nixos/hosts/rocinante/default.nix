{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ./filesystem.nix
    ./disko.nix
  ];

  config = {
    time.timeZone = mkForce "America/Sao_Paulo";

    # --- Hardware & CPU (MacBook Pro 4,1 - Penryn Core 2 Duo) ---
    hardware = {
      cpu = {
        enable = true;
        cpuVendor = "intel";
        enableKvm = true;
        improveTCP = true;
      };

      audio = {
        enable = true;
        manager = "pipewire";
      };

      graphics.cards = {
        enable = true;
        acceleration = true;
        gpu = null; # NVIDIA GeForce 8600M GT: usa driver nouveau + Mesa (aceleração por hardware nativa)
      };

      # Firmware redistribuível (essencial para Wi-Fi Broadcom e Microcode Intel)
      enableRedistributableFirmware = true;
    };

    # --- Boot & GRUB híbrido (BIOS i386-pc para VBIOS da NVIDIA + EFI fallback) ---
    system.boot = {
      enable = true;
      bootType = "hybrid-legacy";
      bootManager = "grub";
      device = "/dev/sda";
      plymouth = false;
      silentBoot = true;
    };

    boot = {
      initrd = {
        availableKernelModules = [
          "uhci_hcd"
          "ehci_pci"
          "ahci"
          "firewire_ohci"
          "usb_storage"
          "usbhid"
          "sd_mod"
          "sr_mod"
          "applesmc"
          "btrfs"
        ];
        kernelModules = [
          "applesmc"
          "hid_apple"
        ];
      };

      # Módulos carregados para o hardware do MacBook Pro 4,1
      kernelModules = [
        "applesmc"
        "hid_apple"
        "coretemp"
      ];

      # Teclado Apple: fnmode=1 (teclas multimídia/brilho nativas), swap_opt_cmd=1 (Command/Option físicos)
      extraModprobeConfig = ''
        options hid_apple fnmode=1 swap_opt_cmd=1
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
        "pcie_aspm=force"                  # Força economia de energia nos barramentos PCIe (ICH8-M)
        "zswap.enabled=0"                  # Desativado: ZRAM gerencia 100% da compressão de memória
        "mitigations=off"                  # Desativa mitigações de CPU (ganho de 15-25% em Core 2 Duo Penryn)
        "nowatchdog"                       # Economiza ciclos de CPU desativando lockup detectors
        "nouveau.modeset=1"                # Garante KMS ativo para a GPU NVIDIA GeForce 8600M GT
        "transparent_hugepage=madvise"    # Reduz fragmentação e overhead de memória nos 6 GB RAM
        "elevator=bfq"                     # Scheduler de I/O de baixa latência para o SSD
      ];

      # Tuning avançado de Memória Virtual para ZRAM + 6GB RAM (Canal Assimétrico)
      kernel.sysctl = {
        "vm.swappiness" = 180;             # Com ZRAM: prioriza compactação em RAM antes de tocar o SSD
        "vm.vfs_cache_pressure" = 50;      # Mantém caches de diretórios e inodes em RAM
        "vm.page-cluster" = 0;             # Desativa swap em bloco: essencial para descompactação ZRAM sem latência
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_ratio" = 15;
        "vm.dirty_writeback_centisecs" = 1500;
      };
    };

    # --- ZRAM Swap com LZ4 ---
    # LZ4: menor latência de compressão que zstd — ideal para swap em tempo real
    # no Core 2 Duo (Penryn).
    zramSwap = {
      enable = true;
      algorithm = "lz4";
      memoryPercent = 75; # ~4.5 GB de ZRAM (compactados) — suficiente para os 6 GB RAM
      priority = 100;    # Maior prioridade: kernel usa ZRAM antes do swapfile em disco
    };

    # --- Serviços de Hardware do MacBook Pro ---
    services = {
      # Controle inteligente das ventoinhas do MacBook Pro (curva térmica adaptada para Penryn)
      mbpfan = {
        enable = true;
        settings.general = {
          min_fan1_speed = 2000;
          max_fan1_speed = 6000;
          low_temp = 50;
          high_temp = 68;
          max_temp = 82;
          polling_interval = 2;
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

      thermald.enable = false; # Desativado: usa Intel DPTF (Sandy Bridge+). Penryn/ICH8-M não suporta.
      earlyoom = {
        enable = true;
        freeMemThreshold = 5;
        freeSwapThreshold = 10;
      };
      irqbalance.enable = true;
      acpid.enable = true;

      # Regras UDEV: Permissões de controle de brilho da tela e iluminação do teclado
      udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
        ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/leds/%k/brightness"
      '';

      # Teclado Apple US Mac no X11
      xserver.xkb = {
        layout = "us";
        variant = "mac";
        options = "terminate:ctrl_alt_bksp";
      };
    };

    # Variáveis de aceleração gráfica para Mesa / Nouveau
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nouveau";
      VDPAU_DRIVER = "nouveau";
    };

    # --- Rede Wi-Fi & Fixes de Repetidor ---
    networking = {
      hostName = "rocinante";
      networkmanager = {
        enable = true;
        wifi.scanRandMacAddress = false; # Fix: repetidores rejeitam MAC aleatório
        wifi.powersave = false; # Fix: evita desconexões em repetidores
      };
    };

    # Domínio regulatório Brasil
    hardware.wirelessRegulatoryDatabase = true;

    # --- Pacotes do Sistema ---
    environment.systemPackages = with pkgs; [
      brightnessctl # Controle de brilho da tela e luz do teclado
      pamixer # Controle de volume CLI
      pavucontrol # Controle de volume GUI
      ffmpeg # Codecs de vídeo/áudio para YouTube
      libva-utils
      vdpauinfo
      mesa-demos
      lm_sensors
    ];

    # Teclado no console TTY
    console.useXkbConfig = true;
  };
}
