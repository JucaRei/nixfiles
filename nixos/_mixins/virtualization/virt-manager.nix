{ pkgs, config, username, lib, hostname, ... }:
# let
#   inherit (lib) mkIf mkOption types;
#   cfg = config.virtualization.firmware;
# in
{
  imports = [

  ];

  boot = {
    initrd = {
      kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
        # "vfio_virqfd" ### already in path since kernel 6.2
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];
      availableKernelModules = [
        "virtio_net"
        "virtio_pci"
        "virtio_mmio"
        "virtio_blk"
        "virtio_scsi"
      ];
      postDeviceCommands = ''
        # Set the system time from the hardware clock to work around a
        # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
        # to the *boot time* of the host).
        hwclock -s
      '';
    };
    extraModprobeConfig = ''
      # Needed to run OSX-KVM
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_nsrs=Y
      options kvm report_ignored_msrs=N
    '';


    # #Load VFIO related modules
    # options vfio-pci
    # ids=10de:1c8d,10de:0fb9 #grep PCI_ID /sys/bus/pci/devices/*/uevent
    # Nvidia == ids=10de:1C8D,10de:0FB9  | Intel == ids=8086:3e9b,8086:a348

    # Load VFIO related modules
    # kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];

    # Enable IOMMU
    kernelParams = [
      # Prevents Linux from touching devices which cannot be passed through
      "iommu=pt" # (pass-through)
      "intel_iommu=on" # needs to enable if on intel
    ];
    binfmt = {
      emulatedSystems = [
        "aarch64-linux"
        "armv7l-linux"
        "armv6l-linux"
      ];
    };
  };

  users.groups.libvirtd.members = [ "root" "${username}" ];

  virtualisation = {
    lxd = {
      enable = true;
    };
    libvirtd = {
      enable = true;
      extraConfig = ''
        unix_sock_group = "libvirtd"

        # Needed for virtio-fs
        memory_backing_dir = "/dev/shm/"
      '';
      qemu = {
        verbatimConfig = ''
          namespaces = []
          nographics_allow_host_audio = 1
          user = "${username}"
          group = "kvm"
        '';
        package = pkgs.unstable.qemu_kvm.override { smbdSupport = true; };
        ovmf = {
          enable = true;
          # packages = with pkgs.unstable; [
          #   OVMFFull
          # ];
          packages = with pkgs.unstable; [
            (OVMFFull.override {
              secureBoot = true;
              csmSupport = true;
              httpSupport = true;
              tpmSupport = true;
            }).fd
            # pkgsCross.aarch64-multiplatform.OVMF.fd
          ];
        };
        # runAsRoot = false;
        runAsRoot = true;
        # Is this required for Windows 11?
        swtpm = {
          enable = true;
          package = pkgs.swtpm-tpm2;
        };
      };
      onShutdown = "suspend";
      onBoot = "ignore";
    };
    spiceUSBRedirection.enable = true; # USB redirection in virtual machine
  };

  environment = {
    systemPackages = with pkgs; [
      virt-manager # VM Interface
      spice-gtk
      spice
      spice-protocol
      win-spice
      win-virtio
      swtpm # TPM
      virglrenderer # Virtual OpenGL
      # virt-viewer # Remote VM/
      qemu # UEFI Firmware
      OVMFFull
      # gvfs
      virtiofsd
    ];

    # etc = {
    #   "ovmf/edk2-x86_64-secure-code.fd" = {
    #     source =
    #       config.virtualisation.libvirtd.qemu.package
    #       + "/share/qemu/edk2-x86_64-secure-code.fd";
    #   };
    # "ovmf/OVMF_VARS.fd".source = (ovmfPackage.fd) + /FV/OVMF_VARS.fd;
    # "ovmf/OVMF_CODE.fd".source = (ovmfPackage.fd) + /FV/OVMF_CODE.fd;
    # "ovmf/OVMF.fd".source = (ovmfPackage.fd) + /FV/OVMF.fd;
    # };

    # sessionVariables = {
    #   LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
    # };
  };
  services = {
    spice-vdagentd.enable = true;
    # udev.extraRules = ''
    #   ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /media"
    #   SUBSYSTEMS=="usb", ATTRS{idVendor}=="vendor_id", ATTRS{idProduct}=="product_id", MODE="0660", TAG+="uaccess"
    #   DEVPATH=="/devices/pci0000:00/0000:00:1f.2/host4/*", ENV{UDISKS_SYSTEM}="0"
    #   ENV{ID_SERIAL_SHORT}=="WDC_WD10SPZX-21Z10T0_WD-WX61AA92ZH86", ENV{UDISKS_AUTO}="1", ENV{UDISKS_SYSTEM}="0"
    # '';
    qemuGuest = {
      enable = true;
    };

  };
}
