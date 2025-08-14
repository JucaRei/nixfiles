_: {
  fileSystems =
    let
      btrfsOpts = [ "rw" "noatime" "ssd" "compress-force=zstd:8" "space_cache=v2" "nodatacow" "commit=120" "discard=async" ];
      btrfsOpts2 = [ "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "nodatacow" "commit=120" "discard=async" ];
    in
    {
      "/boot" = {
        # device = "/dev/disk/by-uuid/da486df9-cbc4-4059-b12d-1a9672e39f45";
        device = "/dev/disk/by-label/SYSTEM";
        fsType = "ext4";
        options = [ "rw" "relatime" ];
      };
      "/boot/efi" = {
        # device = "/dev/disk/by-uuid/346D-5AB9";
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
        options = [ "defaults" "umask=0077" "noatime" "nodiratime" ];
      };
      "/" = {
        # device = "/dev/disk/by-uuid/d1e4d48e-99ac-4cd1-98a9-9cdaef51cb32";
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@root" ];
      };
      "/home" = {
        # device = "/dev/disk/by-uuid/d1e4d48e-99ac-4cd1-98a9-9cdaef51cb32";
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@home" ];
      };
      "/.snapshots" = {
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts2 ++ [ "subvol=@snapshots" ];
      };
      "/nix" = {
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts2 ++ [ "subvol=@nix" ];
      };
      "/var/log" = {
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts2 ++ [ "subvol=@log" ];
      };
      "/var/tmp" = {
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@tmp" ];
      };
      "/var/spool" = {
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@spool" ];
      };
      "/var/cache" = {
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@cache" ];
      };
      "/var/lib/libvirt" = {
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts2 ++ [ "subvol=@libvirt" ];
      };
      "/opt" = {
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts2 ++ [ "subvol=@opt" ];
      };
      "/var/lib/gdm" = {
        device = "/dev/disk/by-label/nixtro";
        fsType = "btrfs";
        options = btrfsOpts2 ++ [ "subvol=@gdm" ];
      };
    };
}
