{ pkgs, config, username, lib, hostname, ... }:
let
  # Change this to match your system's CPU.
  platform = "intel";
in
{
  boot = {
    extraModprobeConfig = ''
      # Needed to run OSX-KVM
      options kvm_${platform} nested=1
      options kvm_${platform} emulate_invalid_guest_state=0
      options kvm ignore_nsrs=Y
      options kvm report_ignored_msrs=N
    '';
    binfmt = {
      emulatedSystems = [ "aarch64-linux" "armv7l-linux" "armv6l-linux" "x86_64-windows" ];
    };
  };

  users = {
    groups.libvirtd.members = [
      "root"
      "${username}"
    ];
    users.${username}.extraGroups = [
      "qemu-libvirtd"
      "libvirtd"
      "disk"
    ];
  };
  # nixos 23.11
  programs = {
    virt-manager = { enable = true; };
  };
  virtualisation = {
    lxd = {
      enable = true;
    };
    libvirtd = {
      enable = true;
      extraConfig = ''
        user="${username}"
        unix_sock_group = "libvirtd"

        # Needed for virtio-fs
        memory_backing_dir = "/dev/shm/"
      '';
      qemu = {
        verbatimConfig = ''
          namespaces = []
          user = "+${builtins.toString config.users.users.${username}.uid}"
          # Whether libvirt should dynamically change file ownership
          dynamic_ownership = 0
          cgroup_device_acl = [
              "/dev/kvmfr0",
              "/dev/vfio/vfio", "/dev/vfio/11", "/dev/vfio/12",
              "/dev/null", "/dev/full", "/dev/zero",
              "/dev/random", "/dev/urandom",
              "/dev/ptmx", "/dev/kvm"
            ]
        '';
        package = pkgs.qemu_kvm.override {
          smbdSupport = true;
        };
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
        # runAsRoot = false;
        runAsRoot = true;
        # Is this required for Windows 11?
        swtpm = {
          enable = true;
          package = pkgs.swtpm-tpm2;
        };
      };
      # Stop all running VMs on shutdown.
      onShutdown = "shutdown"; #suspend
      # Don't start any VMs automatically on boot.
      onBoot = "ignore";
    };
    spiceUSBRedirection.enable = true; # USB redirection in virtual machine
  };

  environment = {
    sessionVariables = {
      LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
      # LIBVIRT_DEFAULT_AUTOCONNECT = [ "qemu:///system" ];
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
      libvirt # /A toolkit to interact with the virtualization capabilities of recent versions of Linux (and other OSes)
      virt-viewer # A viewer for remote virtual machines
      bridge-utils
      swtpm # TPM
      libhugetlbfs
      virglrenderer # Virtual OpenGL
      virt-viewer # Remote VM/
      OVMFFull
      gvfs
      virtiofsd
    ];
  };
  services = {
    spice-vdagentd.enable = true;
    # udev.extraRules = ''
    #   ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /media"
    #   SUBSYSTEMS=="usb", ATTRS{idVendor}=="vendor_id", ATTRS{idProduct}=="product_id", MODE="0660", TAG+="uaccess"
    #   DEVPATH=="/devices/pci0000:00/0000:00:1f.2/host4/*", ENV{UDISKS_SYSTEM}="0"
    #   ENV{ID_SERIAL_SHORT}=="WDC_WD10SPZX-21Z10T0_WD-WX61AA92ZH86", ENV{UDISKS_AUTO}="1", ENV{UDISKS_SYSTEM}="0"
    # '';
    # qemuGuest = {
    #   enable = true;
    # };
  };

  # this allows libvirt to use pulseaudio socket
  # which is useful for virt-manager
  hardware.pulseaudio.extraConfig = ''
    load-module module-native-protocol-unix auth-group=qemu-libvirtd socket=/tmp/pulse-socket
  '';

}
