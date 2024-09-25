{ pkgs, config, lib, username, ... }:
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

  # Change this to match your system's CPU.
  platform = "intel";
  # Change this to specify the IOMMU ids you wrote down earlier.
  vfioIds = [
    ### grep PCI_ID /sys/bus/pci/devices/*/uevent

    # Nvidia
    "10de:1c8d" # 01:00.0   video
    "10de:0fb9" # 01:00.1   audio

    # Intel
    # 8086:3e9b   # 00:02.0  video
    # 8086:a348   # 00:02.1  audio
  ];
in
{
  config = {
    specialisation = {
      vm-passthrought = {
        configuration = {
          system.nixos.tags = [ vm-passthrought ];
          boot = {
            loader.grub.configurationName = lib.mkForce "VM Passthrought";


            # Configure kernel options to make sure IOMMU & KVM support is on.
            kernelModules = mkForce [
              "kvm-${platform}"
              "vfio_virqfd"
              "vfio_pci"
              "vfio_iommu_type1"
              "vfio"

              "nvidia"
              "nvidia_modeset"
              "nvidia_uvm"
              "nvidia_drm"
            ];

            kernelParams = mkForce [
              "${platform}_iommu=on"
              "${platform}_iommu=pt"
              "vfio-pci.ids=${concatStringsSep "," vfioIds}"
              # "kvm.ignore_msrs=1"
              # "video=efifb:off"
            ];

            ### For intel-gpu dGPU
            # kernelParams = [
            #   "i915.enable_gvt=1"
            # ];
            extraModprobeConfig = mkForce ''
              # options vfio-pci ids=${builtins.concatStringsSep "," vfioIds}
              # softdep nvidia pre: vfio-pci
              softdep drm pre: vfio-pci
              options kvm ignore_msrs=1 # # This prevents certain (BSOD) crashes in Windows guests.
              options kvmfr static_size_mb=32
              options snd_hda_intel power_save=0
            '';

            # blacklistedKernelModules = mkForce [
            #   "nouveau"
            #   "nvidiafb"
            #   "nvidia"
            #   "nvidia-uvm"
            #   "nvidia-drm"
            #   "nvidia-modeset"
            # ];

            # Kernel modules required by QEMU (KVM) virtual machine
            initrd = mkForce {
              availableKernelModules = [
                "virtio_net"
                "virtio_pci"
                "virtio_mmio"
                "virtio_blk"
                "virtio_scsi"
                #   "vfio_pci"
                #   "vfio"
                #   "vfio_iommu_type1"
                #   "kvmfr"
              ];

              kernelModules = [
                "virtio_balloon"
                "virtio_console"
                "virtio_rng"
                "kvmfr"
              ];

              # postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) ''
              #   # Set the system time from the hardware clock to work around a
              #   # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
              #   # to the *boot time* of the host).
              #   hwclock -s
              # '';
            };
          };

          hardware = {
            opengl = {
              driSupport = true;
              driSupport32Bit = true;
              extraPackages = with pkgs; [
                (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
                libvdpau-va-gl
                intel-media-driver
              ];
            };
          };

          services = {
            xserver.videoDrivers = [ "i915" ];

            udev.extraRules = ''
              SUBSYSTEM=="kvmfr", KERNEL=="kvmfr0", OWNER="${username}", GROUP="kvm", MODE="0660"
            '';
          };
          nixpkgs.config.packageOverrides = pkgs: {
            vaapiIntel = pkgs.vaapiIntel.override {
              enableHybridCodec = true;
            };
          };

          # Add a file for looking-glass to use later. This will allow for viewing the guest VM's screen in a
          # performant way.
          systemd.tmpfiles.rules = [
            "f /dev/shm/looking-glass 0660 ${username} qemu-libvirtd -"
            "f /dev/shm/scream 0660 ${username} qemu-libvirtd -"
          ];

          environment = {
            systemPackages = with pkgs; [
              looking-glass-client
              guestfs-tools
              pciutils

              glxinfo
            ];

            shellAliases = {
              vm-pci = ''lspci -k | grep -E "vfio-pci|NVIDIA"'';
            };

            variables = {
              VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
            };
          };

          virtualisation.libvirtd.hooks.qemu = {
            hugepages_handler = "${hugepage_handler}";
          };

          # GPU passthrough with vfio need memlock
          security.pam.loginLimits = [
            { domain = "*"; type = "-"; item = "memlock"; value = "infinity"; }
          ];
        };
      };
    };
  };
}
