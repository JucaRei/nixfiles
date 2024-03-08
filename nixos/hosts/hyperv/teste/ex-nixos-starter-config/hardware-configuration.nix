# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" =
      {
        device = "none";
        fsType = "tmpfs";
        options = [ "defaults" "size=25%" "mode=755" ];
      };

    "/boot" =
      {
        device = "/dev/disk/by-uuid/CAAA-44EA";
        # device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };

    "/nix" =
      {
        device = "/dev/disk/by-uuid/ce51df6f-a7e4-49bc-b092-43a525cdc727";
        # device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

    "/etc/nixos" =
      {
        device = "/nix/persist/etc/nixos";
        fsType = "none";
        options = [ "bind" ];
      };

    "/var/log" =
      {
        device = "/nix/persist/var/log";
        fsType = "none";
        options = [ "bind" ];
      };
  };

  boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/4e6d5789-9e6e-4861-b254-279bf47f199e";
  # boot.initrd.luks.devices."crypted".device = "/dev/disk/by-label/nixos";

  swapDevices =
    [{
      device = "/dev/disk/by-partuuid/88eee38c-6ea3-461b-b760-f10529c714c0";
      # device = "/dev/disk/by-label/swap";
      randomEncryption.enable = true;
    }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.hypervGuest.enable = true;
}
