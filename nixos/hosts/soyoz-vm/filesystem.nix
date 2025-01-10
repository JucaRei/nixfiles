_: {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/disk-sda-root";
      fsType = "bcachefs";
      options = [
        "compression=zstd:3"
        "background_compression=zstd"
        "block_size=4096"
        "discard"
        "label=nixsystem"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-partlabel/disk-sda-ESP";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
        "defaults"
        "noatime"
        "nodiratime"
        "x-gvfs-hide" # hide from filemanager
      ];
      noCheck = true;
    };
  };
  swapDevices = [{
    device = "/dev/disk/by-partlabel/disk-sda-SWAP";
  }];
}
