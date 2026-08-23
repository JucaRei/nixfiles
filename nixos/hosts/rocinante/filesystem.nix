{ lib, ... }: {
  fileSystems =
    let
      btrfsOpts = [ "rw" "noatime" "ssd" "compress-force=zstd:2" "space_cache=v2" "commit=120" "discard=async" ];
    in
    {
      "/boot/efi" = {
        device = lib.mkForce "/dev/disk/by-label/EFI";
        fsType = "vfat";
        options = [ "defaults" "umask=0077" "noatime" "nodiratime" ];
      };
      "/" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@" ];
      };
      "/home" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@home" ];
      };
      "/.snapshots" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@snapshots" ];
      };
      "/nix" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@nix" ];
      };
      "/var/log" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@var_log" ];
      };

      "/swap" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@swap" ];
      };
    };

  swapDevices = [
    {
      device = "/swap/swapfile";
      priority = 10; # Fallback de emergência: usado APENAS se ZRAM (prioridade 100) encher
    }
  ];
}
