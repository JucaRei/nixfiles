{ pkgs
, lib
, ...
}: {
  # USB auto-mount
  services = {
    gvfs = {
      enable = true;
      package = lib.mkDefault pkgs.unstable.gnome.gvfs;
    };
    udisks2 = {
      enable = true;
      mountOnMedia = true;
      settings = {
        #     "media-automount.conf" = {
        #       defaults = {
        #         mount_defaults = ''
        #           ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /media"
        #         '';
        #       };
        #     };
        #     "71-device-name.rules" = ''
        #       SUBSYSTEMS=="usb", ATTRS{idVendor}=="vendor_id", ATTRS{idProduct}=="product_id", MODE="0660", TAG+="uaccess"
        #     '';
        #     "10-esata.rules" = ''
        #       DEVPATH=="/devices/pci0000:00/0000:00:1f.2/host4/*", ENV{UDISKS_SYSTEM}="0"
        #     '';

        # fix NTFS mount, from https://wiki.archlinux.org/title/NTFS#udisks_support
        "mount_options.conf" = {
          defaults = {
            # ntfs_defaults = "uid=$UID,gid=$GID,noatime,prealloc";
            ntfs_defaults = "uid=$UID,gid=$GID,noatime";
          };
        };
      };
    };
    devmon.enable = true;
  };
  security.polkit = {
    enable = true;
    # extraConfig = "";
  };
}
