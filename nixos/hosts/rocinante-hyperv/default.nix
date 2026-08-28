{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce mkIf;
  isX11 = (config.desktop.display-servers.backend == "x11") || config.services.xserver.enable;
in
{
  imports = [
    ./filesystem.nix
    ./disko.nix
  ];

  config = {
    time.timeZone = mkForce "America/Sao_Paulo";

    # --- Suporte a Binários Dinâmicos (VS Code / Antigravity / Language Servers) ---
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

    # --- Integração Nativa com Windows Hyper-V ---
    virtualisation.hypervGuest.enable = true; # Daemons Hyper-V (VSS, KVP, FCOPY, heartbeat)

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
        gpu = null; # Usa driver Mesa 3D / Hyper-V Framebuffer nativo
      };

      enableRedistributableFirmware = true;
    };

    # --- Boot EFI com GRUB / Plymouth ---
    system.boot = {
      enable = true;
      bootType = "efi";
      bootManager = "grub";
      device = "/dev/sda";
      plymouth = true;
      silentBoot = true;
    };

    boot = {
      # Kernel padrão otimizado
      kernelPackages = pkgs.unstable.linuxPackages_zen;

      supportedFilesystems = [
        "btrfs"
        "vfat"
        "ext4"
      ];

      initrd = {
        systemd.enable = lib.mkForce false;
        supportedFilesystems = [
          "btrfs"
          "vfat"
        ];
        availableKernelModules = [
          # Hyper-V Drivers (Windows Hyper-V)
          "hv_vmbus"
          "hv_storvsc"
          "hv_netvsc"
          "hv_balloon"
          "hv_utils"
          "hyperv_keyboard"
          "hyperv_fb"
          "hid_hyperv"

          # Controladores de Armazenamento & USB
          "ahci"
          "ata_piix"
          "xhci_pci"
          "nvme"
          "usb_storage"
          "usbhid"
          "sd_mod"
          "sr_mod"
          "btrfs"
        ];
        kernelModules = [
          "btrfs"
          "hv_vmbus"
          "hv_storvsc"
          "hv_netvsc"
          "hv_balloon"
          "hv_utils"
        ];
      };

      # Parâmetros de kernel para desempenho e resolução nativa no Hyper-V
      kernelParams = [
        "mitigations=off" # Desativa mitigações para performance máxima na VM
        "nowatchdog"
        "transparent_hugepage=madvise"
        "elevator=none" # VMs com VHDX/SSD se beneficiam de noop/none scheduler
        "video=hyperv_fb:1920x1080" # Fix: Resolução Full HD nativa no console do Hyper-V
      ];

      # Tuning de Memória Virtual para VM
      kernel.sysctl = {
        "vm.swappiness" = 150;
        "vm.vfs_cache_pressure" = 50;
        "vm.page-cluster" = 0;
      };
    };

    # --- ZRAM Swap com LZ4 ---
    zramSwap = {
      enable = true;
      algorithm = "lz4";
      memoryPercent = 50;
      priority = 100;
    };

    # --- Serviços do Sistema ---
    services = {
      # Sincronização de horário NTP
      timesyncd = {
        enable = true;
        servers = [
          "a.st1.ntp.br"
          "b.st1.ntp.br"
          "c.st1.ntp.br"
          "pool.ntp.org"
        ];
      };

      # Desativa fwupd (inútil em VMs)
      fwupd.enable = false;

      earlyoom = {
        enable = true;
        freeMemThreshold = 5;
        freeSwapThreshold = 10;
      };

      irqbalance.enable = true;
      acpid.enable = true;

      # Configurações do X11 / BSPWM
      xserver = mkIf isX11 {
        xkb = {
          layout = "us";
          variant = "mac";
          options = "terminate:ctrl_alt_bksp";
        };
      };

      # SSH para acesso remoto no Hyper-V
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = lib.mkForce true;
          KbdInteractiveAuthentication = lib.mkForce true;
          PermitRootLogin = lib.mkForce "yes";
        };
        startWhenNeeded = lib.mkForce false;
      };
    };

    # --- Rede & DNS ---
    networking = {
      hostName = "rocinante-hyperv";
      search = [ "home.lan" ];
      nameservers = [
        "10.10.10.25" # DNS Local Primário (Technitium + Unbound em dns01.home.lan)
        "1.1.1.1"     # Fallback público Cloudflare
        "8.8.8.8"     # Fallback público Google
      ];
      networkmanager = {
        enable = true;
      };
    };

    # --- Pacotes do Sistema ---
    environment.systemPackages = with pkgs; [
      brightnessctl
      pamixer
      pavucontrol
      ffmpeg
      mesa-demos
      lm_sensors
    ];

    # Teclado no console TTY
    console.useXkbConfig = true;
  };
}
