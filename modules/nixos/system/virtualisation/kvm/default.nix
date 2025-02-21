{ config, lib, pkgs, namespace, ... }:
let
  inherit (lib) mkIf optionalString concatStringsSep length;
  inherit (lib.types) listOf str enum;
  inherit (lib.${namespace}) mkBoolOpt mkOpt enabled;

  cfg = config.${namespace}.virtualisation.kvm;
  user = config.${namespace}.user;
in
{
  options.${namespace}.virtualisation.kvm = {
    enable = mkBoolOpt false "Whether or not to enable KVM virtualisation.";
    vfioIds = mkOpt (listOf str) [ ] "The hardware IDs to pass through to a virtual machine.";
    platform = mkOpt
      (enum [
        "amd"
        "intel"
      ]) "amd" "Which CPU platform the machine is using.";
    # Use `machinectl` and then `machinectl status <name>` to
    # get the unit "*.scope" of the virtual machine.
    machineUnits =
      mkOpt (listOf str) [ ]
        "The systemd *.scope units to wait for before starting Scream.";
  };

  config = mkIf cfg.enable {
    boot = {
      kernelModules = [
        "kvm-${cfg.platform}"
        "vfio_virqfd"
        "vfio_pci"
        "vfio_iommu_type1"
        "vfio"
      ];
      kernelParams = [
        "${cfg.platform}_iommu=on"
        "${cfg.platform}_iommu=pt"
        "kvm.ignore_msrs=1"
        # "vfio-pci.ids=${concatStringsSep "," cfg.vfioIds}"
      ];
      extraModprobeConfig = optionalString (length cfg.vfioIds > 0) ''
        softdep amdgpu pre: vfio vfio-pci
        options vfio-pci ids=${concatStringsSep "," cfg.vfioIds}
      '';
    };

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${user.name} qemu-libvirtd -"
      "f /dev/shm/scream 0660 ${user.name} qemu-libvirtd -"
    ];

    environment.systemPackages = with pkgs; [ virt-manager ];

    virtualisation = {
      libvirtd = {
        enable = true;
        extraConfig = ''
          user="${user.name}"
        '';

        onBoot = "ignore";
        onShutdown = "shutdown";

        qemu = {
          package = pkgs.qemu_kvm;
          ovmf = {
            enable = true;
            packages = [
              (pkgs.OVMF.override {
                secureBoot = true;
                tpmSupport = true;
              }).fd
            ];
          };
          swtpm = enabled;
          verbatimConfig = ''
            namespaces = []
            user = "+${builtins.toString config.users.users.${user.name}.uid}"
          '';
        };
      };

      spiceUSBRedirection = {
        enable = true;
      };
    };

    ${namespace} = {
      user = {
        extraGroups = [
          "qemu-libvirtd"
          "libvirtd"
          "disk"
        ];
      };

      programs = {
        terminal = {
          tools = {
            looking-glass-client = enabled;
          };
        };
      };

      home = {
        extraOptions = {
          systemd.user.services.scream = {
            Unit.Description = "Scream";
            Unit.After = [
              "libvirtd.service"
              "pipewire-pulse.service"
              "pipewire.service"
              "sound.target"
            ] ++ cfg.machineUnits;
            Service.ExecStart = "${pkgs.scream}/bin/scream -n scream -o pulse -m /dev/shm/scream";
            Service.Restart = "always";
            Service.StartLimitIntervalSec = "5";
            Service.StartLimitBurst = "1";
            Install.RequiredBy = cfg.machineUnits;
          };

          dconf = {
            settings = {
              "org/virt-manager/virt-manager" = {
                system-tray = true;
                xmleditor-enabled = true;
              };

              "org/virt-manager/virt-manager/connections" = {
                autoconnect = [ "qemu:///system" ];
                uris = [ "qemu:///system" ];
              };

              "org/virt-manager/virt-manager/stats" = {
                enable-disk-poll = true;
                enable-memory-poll = true;
                enable-net-poll = true;
              };

              "org/virt-manager/virt-manager/console" = {
                resize-guest = 1;
                scaling = 2;
              };

              # "org/virt-manager/virt-manager/new-vm" = {
              #   cpu-default = "host-passthrough";
              # };
            };
          };
        };
      };
    };
  };
}
