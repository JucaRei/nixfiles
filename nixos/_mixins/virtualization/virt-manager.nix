{ pkgs
, config
, username
, lib
, hostname
, ...
}:
let
  hugepage_handler = pkgs.writeShellScript "hp_handler.sh" ''
    xml_file="/var/lib/libvirt/qemu/$1.xml"

    function extract_number() {
        local xml_file=$1
        local number=$(grep -oPm1 "(?<=<memory unit='KiB'>)[^<]+" $xml_file)
        echo $((number/1024))
    }

    function prepare() {
        # Calculate number of hugepages to allocate from memory (in MB)
        HUGEPAGES="$(($1/$(($(grep Hugepagesize /proc/meminfo | ${pkgs.gawk}/bin/gawk '{print $2}')/1024))))"

        echo "Allocating hugepages..."
        echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
        ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)

        TRIES=0
        while (( $ALLOC_PAGES != $HUGEPAGES && $TRIES < 1000 ))
        do
            echo 1 > /proc/sys/vm/compact_memory
            ## defrag ram
            echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
            ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)
            echo "Successfully allocated $ALLOC_PAGES / $HUGEPAGES"
            let TRIES+=1
        done

        if [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ]
        then
            echo "Not able to allocate all hugepages. Reverting..."
            echo 0 > /proc/sys/vm/nr_hugepages
            exit 1
        fi
    }

    function release() {
        echo 0 > /proc/sys/vm/nr_hugepages
    }

    case $2 in
        prepare)
            number=$(extract_number $xml_file)
            prepare $number
            ;;
        release)
            release
            ;;
    esac
  '';
in
{
  boot = {
    initrd = {
      kernelModules = [
        # "vfio_pci"
        # "vfio"
        # "vfio_iommu_type1"
        # "vfio_virqfd" ### already in path since kernel 6.2
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];
      availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" ];
      # postDeviceCommands = ''
      #   # Set the system time from the hardware clock to work around a
      #   # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
      #   # to the *boot time* of the host).
      #   hwclock -s
      # '';
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
    # kernelParams = [
    #   # Prevents Linux from touching devices which cannot be passed through
    #   "iommu=pt" # (pass-through)
    #   "intel_iommu=on" # needs to enable if on intel
    #   "vfio-pci.ids=10de:1c8d,10de:0fb9"
    # ];
    binfmt = {
      emulatedSystems = [ "aarch64-linux" "armv7l-linux" "armv6l-linux" "x86_64-windows" ];
    };
  };

  users.groups.libvirtd.members = [
    "root"
    "${username}"
  ];
  # nixos 23.11
  programs = { virt-manager = { enable = true; }; };
  virtualisation = {
    lxd = { enable = true; };
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
        package = pkgs.qemu_kvm.override { smbdSupport = true; };
        ovmf = {
          enable = true;
          # packages = with pkgs.unstable; [
          #   OVMFFull
          # ];
          packages = with pkgs; [
            (OVMFFull.override {
              secureBoot = true;
              # csmSupport = true;
              httpSupport = true;
              tpmSupport = true;
            }).fd
            # pkgsCross.aarch64-multiplatform.OVMF.fd
          ];
        };
        runAsRoot = false;
        # runAsRoot = true;
        # Is this required for Windows 11?
        swtpm = {
          enable = true;
          package = pkgs.swtpm-tpm2;
        };
      };
      hooks.qemu = {
        hugepages_handler = "${hugepage_handler}";
      };
      onShutdown = "suspend";
      onBoot = "ignore";
    };
    spiceUSBRedirection.enable = true; # USB redirection in virtual machine
  };

  environment = {
    sessionVariables = {
      LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
    };
    systemPackages = with pkgs; [
      qemu # A generic and open source machine emulator and virtualizer
      virt-manager # Desktop user interface for managing virtual machines
      vde2 # Virtual Distributed Ethernet, an Ethernet compliant virtual network
      spice-gtk
      spice
      spice-protocol
      win-spice
      win-virtio
      pciutils # A collection of programs for inspecting and manipulating configuration of PCI devices
      OVMF # Sample UEFI firmware for QEMU and KVM
      seabios # Open source implementation of a 16bit X86 BIOS
      libguestfs # Tools for accessing and modifying virtual machine disk images
      libvirt # A toolkit to interact with the virtualization capabilities of recent versions of Linux (and other OSes)
      virt-viewer # A viewer for remote virtual machines
      bridge-utils
      swtpm # TPM
      libhugetlbfs
      virglrenderer # Virtual OpenGL
      # virt-viewer # Remote VM/
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
