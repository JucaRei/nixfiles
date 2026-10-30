{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  isX11 = (config.desktop.display-servers.backend == "x11") || config.services.xserver.enable;
in
{
  imports = [
    ./filesystem.nix
    ./disko.nix
  ];

  config = {
    hardware.cpu = {
      enable = true;
      cpuVendor = "intel";
      enableKvm = true;
      improveTCP = true;
    };

    system.boot = {
      enable = true;
      bootType = "efi";
      bootManager = "grub";
      device = "/dev/sda";
      plymouth = true;
      silentBoot = true;
    };

    boot = {
      kernelPackages = pkgs.unstable.linuxPackages_zen;
      initrd = {
        systemd.enable = false;
        supportedFilesystems = [
          "btrfs"
          "vfat"
        ];
        availableKernelModules = [
          "virtio_pci"
          "virtio_scsi"
          "virtio_blk"
          "virtio_net"
          "virtio_balloon"
          "virtio_console"
          "virtio_gpu"
          "qxl"
          "bochs_drm"
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

      kernelParams = [
        "mitigations=off"
        "nowatchdog"
        "transparent_hugepage=madvise"
        "elevator=none"
        "video=hyperv_fb:1920x1080"
      ];

      kernel.sysctl = {
        "vm.swappiness" = 150;
        "vm.vfs_cache_pressure" = 50;
        "vm.page-cluster" = 0;
      };
    };

    zramSwap = {
      enable = true;
      algorithm = "lz4";
      memoryPercent = 50;
      priority = 100;
    };

    services = {
      xserver = mkIf isX11 {
        xkb = {
          layout = "us";
          variant = "intl";
          options = "terminate:ctrl_alt_bksp";
        };
      };

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          KbdInteractiveAuthentication = true;
          PermitRootLogin = "yes";
        };
        startWhenNeeded = false;
      };
    };

    networking = {
      hostName = "rocinante-vm";
      search = [ "home.lan" ];
      nameservers = [
        "10.10.10.25"
        "1.1.1.1"
        "8.8.8.8"
      ];
      networkmanager.enable = true;
    };

    environment.systemPackages = with pkgs; [
      brightnessctl
      pamixer
      pavucontrol
      ffmpeg
      mesa-demos
      lm_sensors
      spice-vdagent
    ];
  };
}
