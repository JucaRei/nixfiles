{ config, lib, pkgs, username, ... }:
let
  inherit (lib) mkOption optionals mkIf mkForce length concatStringsSep optionalString;
  inherit (lib.types) listOf bool str enum;
  cfg = config.system.services.virtualisation.kvm;
  user = "${username}";
in
{
  options = {
    system.services.virtualisation.kvm = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Whether or not to enable KVM virtualisation.";
      };
      vfioIds = mkOption {
        type = listOf str;
        default = [ ];
        description = "The hardware IDs to pass through to a virtual machine.";
      };
      platform = mkOption {
        type = enum [ "amd" "intel" ];
        default = "intel";
        description = "Which CPU platform the machine is using.";
      };
      # Use `machinectl` and then `machinectl status <name>` to
      # get the unit "*.scope" of the virtual machine.
      machineUnits = mkOption {
        type = listOf str;
        default = [ ];
        description = "The systemd *.scope units to wait for before starting Scream.";
      };
    };
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
      extraModprobeConfig =
        if (cfg.platform == "amd") then
          (optionalString (length cfg.vfioIds > 0) ''
            softdep amdgpu pre: vfio vfio-pci
            options vfio-pci ids=${concatStringsSep "," cfg.vfioIds}
          '')
        else if (config.hardware.graphics.cards.gpu == "nvidia" || config.hardware.graphics.cards.gpu == "hybrid-nvidia") then
          (optionalString (length cfg.vfioIds > 0) ''
            softdep nvidia pre: vfio vfio-pci
            options vfio-pci ids=${concatStringsSep "," cfg.vfioIds}
          '')
        else
        # (cfg.platform == "intel")
        #   (optionalString (length cfg.vfioIds > 0) ''
        #     softdep snd_hda_intel pre: vfio vfio-pci
        #     softdep snd_hda_codec_hdmi pre: vfio vfio-pci
        #     softdep i915 pre: vfio vfio-pci
        #     options vfio-pci ids=${concatStringsSep "," cfg.vfioIds}
        #   '')
          (cfg.platform == "intel")
            (optionalString (length cfg.vfioIds > 0) ''
              softdep drm pre: vfio vfio-pci
              options vfio-pci ids=${concatStringsSep "," cfg.vfioIds}
            '')
        # ++ mkIf (cfg.platform == "intel")
        #   (optionalString (length cfg.vfioIds > 0) ''
        #     softdep i915 pre: vfio vfio-pci
        #     options vfio-pci ids=${concatStringsSep "," cfg.vfioIds}
        #   '')
        # ++
        # mkIf (config.hardware.graphics.cards.gpu == "nvidia" || config.hardware.graphics.cards.gpu == "hybrid-nvidia") (optionalString (length cfg.vfioIds > 0) ''
        #   softdep drm pre: vfio vfio-pci
        #   options vfio-pci ids=${concatStringsSep "," cfg.vfioIds}
        # '')
      ;
    };

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${user} qemu-libvirtd -"
      "f /dev/shm/scream 0660 ${user} qemu-libvirtd -"
    ];

    programs = {
      virt-manager = {
        enable = true;
        package = pkgs.virt-manager;
      };
      dconf = {
        enable = true;
        profiles = {
          user = {
            databases = [{
              settings = {
                "org/virt-manager/virt-manager" = {
                  xmleditor-enabled = true;
                };
                "org/virt-manager/virt-manager/connections" = {
                  autoconnect = [ "qemu:///system" ];
                  uris = [ "qemu:///system" ];
                };
              };
            }];
          };
        };
      };
    };

    services.spice-vdagentd = {
      enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
        # virt-manager
        # looking-glass-client
        spice-gtk # fix usb redirect
        virtiofsd
      ];

      etc = {
        "looking-glass-client.ini" = {
          user = "+${toString config.users.users.${user}.uid}";
          source = ./client.ini;
        };
      };
    };

    #     persist.state.homeDirectories = [
    #       ".config/containers"
    #     ];

    #     persist.state.directories = lib.mkIf (devInfo.fileSystem != "zfs") [
    #       "/var/lib/docker"
    #       "/var/lib/libvirt"
    #       "/var/lib/containers"
    #     ];

    virtualisation = {
      libvirtd = {
        enable = true;
        extraConfig = ''
          user="${user}"
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
          runAsRoot = true;
          swtpm = {
            enable = true;
            package = pkgs.swtpm;
          };
          verbatimConfig = ''
            namespaces = []
            # user = "+${builtins.toString config.users.users.${username}.uid}"

            # Whether libvirt should dynamically change file ownership
            # to match the configured user/group above. Defaults to 1.
            # Set to 0 to disable file ownership changes
            dynamic_ownership = 0
          '';
        };
      };
      spiceUSBRedirection = {
        enable = true;
      };
    };

    users.users = {
      ${username} = {
        extraGroups = [
          "qemu-libvirtd"
          "libvirtd"
          "disk"
        ];
      };
      "qemu-libvirtd" = {
        extraGroups = optionals (!config.virtualisation.libvirtd.qemu.runAsRoot) [ "kvm" "input" ];
      };
    };

    # systemd.user.services.scream = {
    #   Unit.Description = "Scream";
    #   Unit.After = [
    #     "libvirtd.service"
    #     "pipewire-pulse.service"
    #     "pipewire.service"
    #     "sound.target"
    #   ] ++ cfg.machineUnits;
    #   Service.ExecStart = "${pkgs.scream}/bin/scream -n scream -o pulse -m /dev/shm/scream";
    #   Service.Restart = "always";
    #   Service.StartLimitIntervalSec = "5";
    #   Service.StartLimitBurst = "1";
    #   Install.RequiredBy = cfg.machineUnits;
    # };

    ## cross compilation of aarch64 uefi currently broken
    ## link existing extracted from fedora package
    # system.activationScripts.aarch64-ovmf = lib.mkIf (!isServer) {
    #   text = ''
    #     rm -f /run/libvirt/nix-ovmf/AAVMF_*
    #     mkdir -p /run/libvirt/nix-ovmf || true
    #     ${pkgs.zstd}/bin/zstd -d ${../misc/AAVMF_CODE.fd.zst} -o /run/libvirt/nix-ovmf/AAVMF_CODE.fd
    #     ${pkgs.zstd}/bin/zstd -d ${../misc/AAVMF_VARS.fd.zst} -o /run/libvirt/nix-ovmf/AAVMF_VARS.fd
    #   '';
    # };
  };
}
