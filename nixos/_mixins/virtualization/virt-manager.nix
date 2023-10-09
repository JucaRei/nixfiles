{ pkgs, config, username, lib, hostname, ... }:
# let
#   inherit (lib) mkIf mkOption types;
#   cfg = config.virtualization.firmware;
# in
{

  boot = {
    # kernelParams = [ "intel_iommu=on" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ]; # or amd_iommu (cpu)
    # kernelModules = [ "vendor-reset" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
    # extraModulePackages = [ config.boot.kernelPackages.vendor-reset ]; # Presumably fix for GPU Reset Bug
    # kernelPatches = [
    #   {
    #     name = "vendor-reset-reqs-and-other-stuff";
    #     patch = null;
    #     extraConfig = ''
    #       FTRACE y
    #       KPROBES y
    #       FUNCTION_TRACER y
    #       HWLAT_TRACER y
    #       TIMERLAT_TRACER y
    #       IRQSOFF_TRACER y
    #       OSNOISE_TRACER y
    #       PCI_QUIRKS y
    #       KALLSYMS y
    #       KALLSYMS_ALL y
    #     '';
    #   }
    # ];
    initrd = {
      kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
        # "vfio_virqfd"  ## zen not enabled
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
      options kvm ignore_nsrs=1
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
    libvirtd = {
      enable = true;
      qemu = {
        verbatimConfig = ''
          namespaces = []
          nographics_allow_host_audio = 1
          user = "${username}"
          group = "kvm"
        '';
        package = pkgs.unstable.qemu_kvm;
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
        runAsRoot = true;
        swtpm.enable = true;
      };
      onShutdown = "suspend";
      onBoot = "ignore";
    };
    spiceUSBRedirection.enable = true; # USB redirection in virtual machine
  };

  environment = {
    systemPackages = with pkgs; [
      virt-manager
      spice-gtk
      spice
      spice-protocol
      win-spice
      win-virtio
      swtpm
      # virt-viewer
      qemu
      OVMFFull
      gvfs
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
  };
  services.spice-vdagentd.enable = true;
}
