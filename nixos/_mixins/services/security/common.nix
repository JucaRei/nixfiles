_: {
  security = {
    polkit = {
      enable = true;
      extraConfig = ''
        /* Allow users in the wheel group to manage the libvirt daemon without authentication */
        polkit.addRule(function(action, subject) {
          if (action.id == "org.libvirt.unix.manage" && subject.isInGroup("libvirtd")) {
            return polkit.Result.YES;
          }
        });
        /* Allow users in wheel group to manage systemd units without authentication */
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
            subject.isInGroup("wheel")) {
              return polkit.Result.YES;
            }
          }
        );
        polkit.addRule(function(action, subject) {
          var YES = polkit.Result.YES;
          // NOTE: there must be a comma at the end of each line except for the last:
          var permission = {
          // required for udisks1:
          // "org.freedesktop.udisks.filesystem-mount": YES,
          // "org.freedesktop.udisks.luks-unlock": YES,
          // "org.freedesktop.udisks.drive-eject": YES,
          // "org.freedesktop.udisks.drive-detach": YES,
          // required for udisks2:
            "org.freedesktop.udisks2.filesystem-mount": YES,
            "org.freedesktop.udisks2.filesystem-mount-system": YES,
            "org.freedesktop.udisks2.encrypted-unlock": YES,
            "org.freedesktop.udisks2.encrypted-unlock-system": YES,
            "org.freedesktop.udisks2.eject-media": YES,
            "org.freedesktop.udisks2.eject-media-system": YES,
            "org.freedesktop.udisks2.power-off-drive": YES,
            "org.freedesktop.udisks2.power-off-drive-system": YES,
            // required for udisks2 if using udiskie from another seat (e.g. systemd):
            "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
            "org.freedesktop.udisks2.filesystem-unmount-others": YES,
            "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
            "org.freedesktop.udisks2.eject-media-other-seat": YES,
            "org.freedesktop.udisks2.power-off-drive-other-seat": YES
          };
          if (subject.isInGroup("storage")) {
            return permission[action.id];
          }
        });

        polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("users")
            && (
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
              action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
            )
          )
        {
          return polkit.Result.YES;
        }
        });
      '';
    };
    # For Flatpak
    unprivilegedUsernsClone = true;
    pam = {
      mount = {
        enable = true;
      };
    };
  };
}
