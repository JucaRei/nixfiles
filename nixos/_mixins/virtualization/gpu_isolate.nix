{
  pkgs,
  lib,
  config,
  username,
  ...
}: let
  # GTX 1050
  gpuIDs = [
    "10de:1c8d" # Graphics
    "10de:0fb9" # Audio
  ];
in {
  options.vfio.enable = with lib;
    mkOption {
      description = "Whether to enable VFIO";
      type = types.bool;
      default = true;
    };

  config = let
    cfg = config.vfio;
  in {
    boot = {
      initrd = {
        kernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
          "kvmfr"
          # "vfio_virqfd" ## already in path since kernel 6.2

          # "clearcpuid=514" # Fixes certain wine games crash on launch
          #"nvidia"
          #"nvidia_modeset"
          #"nvidia_uvm"
          #"nvidia_drm"
        ];
        preDeviceCommands = ''
          # PCI devices to not load and use vfio-pci insted for
          #           gpu         gpu-audio
          DEVS="0000:01:00.0 0000:01:00.1"
          for DEV in $DEVS; do
            echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
          done
          modprobe -i vfio-pci

          # from https://forums.unraid.net/topic/83680-solved-nvidia-gpu-pass-through-via-rom-edit-method/?do=findComment&comment=775838
          #
          # fixes: "vfio-pci 0000:0d:00.0: BAR 1: can't reserve [mem
          # 0xb0000000-0xbfffffff 64bit pref]" error preventing video from being
          # loaded in vm
          echo 0 > /sys/class/vtconsole/vtcon0/bind
          echo 0 > /sys/class/vtconsole/vtcon1/bind
          echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
        '';
      };
      # kernelModules = [
      #   # "vfio-pci"
      #   "clearcpuid=514" # Fixes certain wine games crash on launch
      #   "nvidia"
      #   "nvidia_modeset"
      #   "nvidia_uvm"
      #   "nvidia_drm"
      # ];

      kernelParams =
        [
          # enable IOMMU
          "intel_iommu=on"
          "intel_iommu=pt"
          "pcie_aspm=off"
          "fbcon=map:1"
          "pci-stub.ids=10de:1c8d,10de:0fb9"
          "kvm.ignore_msrs=1"
          "kvm.report_ignored_msrs=0"
          "vfio_iommu_type1.allow_unsafe_interrupts=1"
          # "amd_iommu=on"
        ]
        ++ lib.optional cfg.enable
        # isolate the GPU
        ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
      extraModprobeConfig = ''
        options vfio-pci ids=10de:1c8d,10de:0fb9
        softdep nvidia pre: vfio-pci
      '';

      blacklistedKernelModules =
        lib.mkForce ["nvidia" "nouveau" "nvidia_drm" "nvidia_modeset"];

      kernelModules = ["pci_stub"];
    };

    # VFIO Packages installed
    environment.systemPackages = with pkgs; [
      virt-manager
      looking-glass-client
      guestfs-tools
      # scream-receivers
      # gnome3.dconf # needed for saving settings in virt-manager
      libguestfs # needed to virt-sparsify qcow2 files
    ];

    # Add binaries to path so that hooks can use it
    systemd = {
      tmpfiles.rules = [
        "f /dev/shm/scream 0660 ${username} qemu-libvirtd -"
        "f /dev/shm/looking-glass 0660 ${username} qemu-libvirtd -"
      ];
      # services.libvirtd = {
      #   path =
      #     let
      #       env = pkgs.buildEnv {
      #         name = "qemu-hook-env";
      #         paths = with pkgs; [
      #           bash
      #           libvirt
      #           kmod
      #           systemd
      #           ripgrep
      #           sd
      #         ];
      #       };
      #     in
      #     [ env ];

      #   #   preStart =
      #   #     ''
      #   #       mkdir -p /var/lib/libvirt/hooks
      #   #       mkdir -p /var/lib/libvirt/hooks/qemu.d/win10/prepare/begin
      #   #       mkdir -p /var/lib/libvirt/hooks/qemu.d/win10/release/end
      #   #       mkdir -p /var/lib/libvirt/vgabios

      #   #       ln -sf /home/owner/Desktop/Sync/Files/Linux_Config/symlinks/qemu /var/lib/libvirt/hooks/qemu
      #   #       ln -sf /home/owner/Desktop/Sync/Files/Linux_Config/symlinks/kvm.conf /var/lib/libvirt/hooks/kvm.conf
      #   #       ln -sf /home/owner/Desktop/Sync/Files/Linux_Config/symlinks/start.sh /var/lib/libvirt/hooks/qemu.d/win10/prepare/begin/start.sh
      #   #       ln -sf /home/owner/Desktop/Sync/Files/Linux_Config/symlinks/stop.sh /var/lib/libvirt/hooks/qemu.d/win10/release/end/stop.sh
      #   #       ln -sf /home/owner/Desktop/Sync/Files/Linux_Config/symlinks/patched.rom /var/lib/libvirt/vgabios/patched.rom

      #   #       chmod +x /var/lib/libvirt/hooks/qemu
      #   #       chmod +x /var/lib/libvirt/hooks/kvm.conf
      #   #       chmod +x /var/lib/libvirt/hooks/qemu.d/win10/prepare/begin/start.sh
      #   #       chmod +x /var/lib/libvirt/hooks/qemu.d/win10/release/end/stop.sh
      #   #     '';
      #   # };
      # };

      ### Home manager
      user.services.scream-ivshmem = {
        enable = true;
        description = "Scream IVSHMEM";
        serviceConfig = {
          ExecStart = "${pkgs.scream}/bin/scream-ivshmem-pulse /dev/shm/scream";
          Restart = "always";
        };
        wantedBy = ["multi-user.target"];
        requires = ["pulseaudio.service"];
      };
    };
  };
}
# https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html
# https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/
# https://gist.github.com/CRTified/43b7ce84cd238673f7f24652c85980b3

