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

    # --- Hardware & Virtualização Proxmox / QEMU KVM ---
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
        gpu = null; # Usa driver Mesa 3D / VirtIO-GPU / QXL nativo
      };

      enableRedistributableFirmware = true;
    };

    # --- Boot EFI com GRUB / Plymouth ---
    system.boot = {
      enable = true;
      bootType = "efi";
      bootManager = "grub";
      device = "/dev/vda";
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
          # VirtIO Drivers (Proxmox / KVM)
          "virtio_pci"
          "virtio_scsi"
          "virtio_blk"
          "virtio_net"
          "virtio_balloon"
          "virtio_console"
          "virtio_gpu"
          "qxl"
          "bochs_drm"
          # Controladores de Armazenamento & USB
          "ahci"
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
          "virtio_balloon"
          "virtio_net"
          "virtio_pci"
        ];
      };

      # Parâmetros de kernel para desempenho em VM
      kernelParams = [
        "mitigations=off" # Desativa mitigações para performance máxima na VM
        "nowatchdog"
        "transparent_hugepage=madvise"
        "elevator=none" # VMs com SSD/VirtIO se beneficiam de noop/none scheduler
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

    # --- Serviços de Integração Proxmox / QEMU ---
    services = {
      # QEMU Guest Agent (relatórios de IP, fsfreeze para backup consistente, shutdown limpo no PVE)
      qemuGuest.enable = true;

      # SPICE vdagent (Redimensionamento automático de tela no noVNC/SPICE e clipboard compartilhado)
      spice-vdagentd.enable = true;

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

      # SSH para acesso remoto no laboratório Proxmox
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

    # --- Rede & DNS Technitium ---
    networking = {
      hostName = "rocinante-vm";
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
      spice-vdagent
    ];

    # Teclado no console TTY
    console.useXkbConfig = true;
  };
}
