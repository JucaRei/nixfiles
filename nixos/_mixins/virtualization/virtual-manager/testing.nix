{ config, lib, pkgs, username, ... }:
with lib;
let
  cfg = config.services.virtualisation.kvm;
in
{
  options.services.virtualisation.kvm = {
    enable = mkEnableOption "enable kvm virtualisation";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      sessionVariables = {
        LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
      };
      systemPackages = with pkgs; [
        libguestfs
        win-virtio
        win-spice
        virt-manager
        virt-viewer
      ];
    };

    virtualisation = {
      kvmgt = {
        enable = true;
        # vgpus = {
        #   "i915-GVTg_V5_8" = {
        #     uuid = [ "d3410e6a-eba5-11ee-bd7b-17759c22f46c" ]; # uuid generated with 'nix shell nixpkgs#libossp_uuid -c uuid'
        #   };
      };
      spiceUSBRedirection.enable = true;

      libvirtd = {
        enable = true;
        allowedBridges = [
          "nm-bridge"
          "virbr0"
        ];
        onBoot = "ignore";
        onShutdown = "shutdown";
        qemu = {
          runAsRoot = true; # false
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [ pkgs.OVMFFull.fd ];
          };

          verbatimConfig = ''
            namespaces = []

            # Whether libvirt should dynamically change file ownership
            dynamic_ownership = 0
          '';
        };
      };
    };

    users = {
      users = {
        ${username} = {
          extraGroups =
            lib.optionals (!config.virtualisation.libvirtd.qemu.runAsRoot) [
              "qemu-libvirtd"
              "libvirtd"
              "disk"
            ];
        };

        "qemu-libvirtd" = {
          extraGroups =
            lib.optionals (!config.virtualisation.libvirtd.qemu.runAsRoot)
              [ "kvm" "input" ];
        };
      };
    };

    # this allows libvirt to use pulseaudio socket
    # which is useful for virt-manager
    hardware.pulseaudio.extraConfig = ''
      load-module module-native-protocol-unix auth-group=qemu-libvirtd socket=/tmp/pulse-socket
    '';
  };
}
