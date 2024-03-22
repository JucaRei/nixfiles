{ pkgs, config, lib, ... }:
with lib;
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
    kernelModules = mkForce [
      "vfio_pci"
    ];

    ### For intel-gpu dGPU
    # kernelParams = [
    #   "iommu=pt" # (pass-through)
    #   "i915.enable_gvt=1"
    #   "kvm.ignore_msrs=1"
    #   "intel_iommu=on"
    # ];
    extraModprobeConfig = mkForce ''
      # Change to your GPU's vendor ID and device ID
      # options vfio-pci ids=10de:1c8d,10de:0fb9
      options vfio-pci ids=10de:1c8d
    '';
    ### grep PCI_ID /sys/bus/pci/devices/*/uevent
    #Nvidia-video = 10de:1c8d   01:00.0
    #Nvidia-audio = 10de:0fb9   01:00.1
    #Intel-video = 8086:3e9b    00:02.0
    #Intel-audio = 18086:a348   00:02.1

    blacklistedKernelModules = mkForce [ "nouveau" "nvidiafb" "nvidia" "nvidia-uvm" "nvidia-drm" "nvidia-modeset" ];

    # Kernel modules required by QEMU (KVM) virtual machine
    initrd = mkForce {
      postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) ''
        # Set the system time from the hardware clock to work around a
        # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
        # to the *boot time* of the host).
        hwclock -s
      '';

      availableKernelModules = mkForce [
        "virtio_net"
        "virtio_pci"
        "virtio_mmio"
        "virtio_blk"
        "virtio_scsi"
      ];

      kernelModules = mkForce [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];
    };
  };
  virtualisation.libvirtd.hooks.qemu = {
    hugepages_handler = "${hugepage_handler}";
  };
}
