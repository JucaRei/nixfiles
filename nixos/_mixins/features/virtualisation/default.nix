{ config, lib, pkgs, username, ... }:
let
  inherit (lib) mkIf mkEnableOption optionals;
  cfg = config.features.virtualisation;
in
{
  options = {
    features.virtualisation = {
      enable = mkEnableOption "Whether enables virtualisation packages.";
    };
  };
  config = mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.unstable.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [
              (pkgs.OVMF.override {
                secureBoot = true;
                tpmSupport = true;
              }).fd
            ];
          };
        };
        onBoot = "ignore";
        onShutdown = "shutdown";
      };
      spiceUSBRedirection = {
        enable = true;
      };
    };

    programs = {
      virt-manager.enable = true;
      dconf = {
        enable = true;
        profiles = {
          user = {
            databases = [{
              settings = with lib.gvariant; {
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

    services.spice-vdagentd.enable = true; # enables clipboard sharing between host and guest

    environment.systemPackages = [ pkgs.virtiofsd ];

    #     persist.state.homeDirectories = [
    #       ".config/containers"
    #     ];

    #     persist.state.directories = lib.mkIf (devInfo.fileSystem != "zfs") [
    #       "/var/lib/docker"
    #       "/var/lib/libvirt"
    #       "/var/lib/containers"
    #     ];

    users.users = {
      ${username} = {
        extraGroups = [ "libvirtd" ];
      };
      "qemu-libvirtd" = {
        extraGroups = optionals (!config.virtualisation.libvirtd.qemu.runAsRoot) [ "kvm" "input" ];
      };
    };

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
