{ config, pkgs, lib, ... }:

let
  cfg = config.services.virt;
in
{
  options.services.virt.libvirt = {
    enable = lib.mkEnableOption "Libvirt tools";

    managerPackage = lib.mkPackageOption pkgs "virt-manager" { };

    viewerPackage = lib.mkPackageOption pkgs "virt-viewer" { };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = with pkgs; [
        libguestfs
        guestfs-tools
      ];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.libvirt.enable {
      home.packages = [ cfg.libvirt.managerPackage cfg.libvirt.viewerPackage ] ++ cfg.libvirt.extraPackages;

      dconf.settings = {
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
    })
  ];
}
