_: {
  fileSystems =
    let
      btrfsOpts = [ "rw" "noatime" "ssd" "compress-force=zstd:2" "space_cache=v2" "commit=120" "discard=async" ];
    in
    {
      "/boot/efi" = {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
        options = [ "defaults" "umask=0077" "noatime" "nodiratime" ];
      };
      "/" = {
        device = "/dev/disk/by-label/Debian";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@" ];
      };
      "/home" = {
        device = "/dev/disk/by-label/Debian";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@home" ];
      };
      "/.snapshots" = {
        device = "/dev/disk/by-label/Debian";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@snapshots" ];
      };
      "/nix" = {
        device = "/dev/disk/by-label/Debian";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@nix" ];
      };
      "/var/log" = {
        device = "/dev/disk/by-label/Debian";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@var_log" ];
      };
      "/var/cache/apt" = {
        device = "/dev/disk/by-label/Debian";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@var_cache_apt" ];
      };
      "/swap" = {
        device = "/dev/disk/by-label/Debian";
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
