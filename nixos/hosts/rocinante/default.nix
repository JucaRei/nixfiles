{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce mkIf mkDefault;
  isX11 = (config.desktop.display-servers.backend == "x11") || config.services.xserver.enable;
in
{
  imports = [
    ./filesystem.nix
    ./disko-legacy.nix
    # ./disko.nix # Legado GPT/EFI
  ];

  config = {
    time.timeZone = mkForce "America/Sao_Paulo";

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        openssl
        curl
        glib
        util-linux
        icu
      ];
    };

    # Permitir broadcom-sta apenas no host rocinante (hardware específico)
    nixpkgs.config.permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-63-7.2"
      "broadcom-sta-6.30.223.271-63-7.1.9"
      "broadcom-sta-6.30.223.271-63-7.1.7"
      "broadcom-sta-6.30.223.271-63-7.1.5"
      "broadcom-sta-6.30.223.271-63-7.1"
      "broadcom-sta-6.30.223.271-59-6.17.9"
      "broadcom-sta-6.30.223.271-63-6.18.43"
      "broadcom-sta-6.30.223.271-63-6.18"
      "broadcom-sta-6.30.223.271-59-6.18.40"
      "broadcom-sta-6.30.223.271-59-6.18"
      "broadcom-sta-6.30.223.271-59-6.6.145"
      "broadcom-sta-6.30.223.271-59-6.6"
      "broadcom-sta-6.30.223.271-63-6.6"
      "broadcom-sta-6.30.223.271-59-5.15.212"
      "broadcom-sta-6.30.223.271-59-5.15"
      "broadcom-sta"
    ];

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
        gpu = null; # Padrão: driver open-source nouveau + Mesa nativa
      };

      # Firmware redistribuível (essencial para Wi-Fi Broadcom e Microcode Intel)
      enableRedistributableFirmware = true;
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

      supportedFilesystems = [
        "btrfs"
        "vfat"
        "ext4"
      ];

      initrd = {
        systemd.enable = lib.mkForce false; # Evita falhas de montagem do /sysroot em hardware legado Intel ICH8-M
        supportedFilesystems = [
          "btrfs"
          "vfat"
        ];
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
        ];
        kernelModules = [
          "btrfs"
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
        "pcie_aspm=force" # Força economia de energia nos barramentos PCIe (ICH8-M)
        "zswap.enabled=0" # Desativado: ZRAM gerencia 100% da compressão de memória
        "mitigations=off" # Desativa mitigações de CPU (ganho de 15-25% em Core 2 Duo Penryn)
        "nowatchdog" # Economiza ciclos de CPU desativando lockup detectors
        "nouveau.modeset=1" # Garante KMS ativo para a GPU NVIDIA GeForce 8600M GT
        "transparent_hugepage=madvise" # Reduz fragmentação e overhead de memória nos 6 GB RAM
        "elevator=bfq" # Scheduler de I/O de baixa latência para o SSD
      ];

      # Tuning avançado de Memória Virtual para ZRAM + 6GB RAM (Canal Assimétrico)
      kernel.sysctl = {
        "vm.swappiness" = 180; # Com ZRAM: prioriza compactação em RAM antes de tocar o SSD
        "vm.vfs_cache_pressure" = 50; # Mantém caches de diretórios e inodes em RAM
        "vm.page-cluster" = 0; # Desativa swap em bloco: essencial para descompactação ZRAM sem latência
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
      priority = 100; # Maior prioridade: kernel usa ZRAM antes do swapfile em disco
    };

    # --- Serviços de Hardware do MacBook Pro ---
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
          max_temp = 60; # Acima de 60°C opera na rotação máxima (6000 RPM)
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

      # Sincronização automática de relógio/NTP (corrige bateria RTC/PRAM descarregada em Macs antigos)
      timesyncd = {
        enable = true;
        servers = [
          "a.st1.ntp.br"
          "b.st1.ntp.br"
          "c.st1.ntp.br"
          "pool.ntp.org"
        ];
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

        # Teclado Apple US Mac no X11
        xkb = {
          layout = "us";
          variant = "mac";
          options = "terminate:ctrl_alt_bksp";
        };
      };

      # SSH com autenticação por senha habilitada e serviço contínuo (apenas no rocinante)
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = lib.mkForce true;
          KbdInteractiveAuthentication = lib.mkForce true;
          PermitRootLogin = lib.mkDefault "no";
        };
        startWhenNeeded = lib.mkForce true;
      };
    };

    # Variáveis de aceleração gráfica para Mesa / Nouveau (padrão)
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = mkDefault "nouveau";
      VDPAU_DRIVER = mkDefault "nouveau";
    };

    # --- Rede Wi-Fi & Fixes de Repetidor ---
    networking = {
      hostName = "rocinante";
      search = [ "home.lan" ];
      nameservers = [
        "10.10.10.25" # DNS Local (Technitium DNS Server + Unbound em dns01.home.lan)
        "10.10.10.26" # Fallback (Technitium DNS Server + Unbound em dns02.home.lan)
        "1.1.1.1" # Fallback público Cloudflare
        "8.8.8.8" # Fallback público Google
      ];
      networkmanager = {
        enable = true;
        wifi = {
          scanRandMacAddress = false; # Fix: repetidores rejeitam MAC aleatório ao escanear
          powersave = false; # Fix: evita desconexões e perda de pacotes em repetidores
          macAddress = "preserve"; # Fix: mantém MAC físico permanente para evitar falhas de ARP no repetidor
        };
      };
    };

    # Domínio regulatório Brasil
    hardware.wirelessRegulatoryDatabase = true;

    # --- Pacotes do Sistema ---
    environment.systemPackages = with pkgs; [
      libva-utils
      vdpauinfo
      mesa-demos
      lm_sensors
      gptfdisk
    ];

    # Teclado no console TTY
    console.useXkbConfig = true;

    # --- Specialisation: Boot alternativo com Kernel 6.6 LTS + Driver NVIDIA 340 Legacy ---
    specialisation = {
      nvidia = {
        inheritParentConfig = true;
        configuration = {
          system.nixos.tags = [ "nvidia-kernel-6.6" ];
          boot = {
            kernelPackages = mkForce pkgs.linuxPackages_6_6;
            kernelParams = mkForce [
              "zswap.enabled=0"
              "mitigations=off"
              "nowatchdog"
              "nouveau.modeset=0"
              "transparent_hugepage=madvise"
              "elevator=bfq"
            ];
          };
          hardware.graphics.cards.gpu = mkForce "nvidia-legacy";
        };
      };
    };
  };
}
