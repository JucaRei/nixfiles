{ pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      generationsDir.copyKernels = true;
    };
  };

  services = {
    openssh.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        lightdm = {
          enable = true;
          greeters.gtk = {
            enable = true;
            cursorTheme.name = "Yaru";
            cursorTheme.package = pkgs.yaru-theme;
            cursorTheme.size = 24;
            iconTheme.name = lib.mkDefault "Yaru-magenta-dark";
            iconTheme.package = pkgs.yaru-theme;
            theme.name = lib.mkDefault "Yaru-magenta-dark";
            theme.package = pkgs.yaru-theme;
            indicators = [
              "~session"
              "~host"
              "~spacer"
              "~clock"
              "~spacer"
              "~a11y"
              "~power"
            ];
            # https://github.com/Xubuntu/lightdm-gtk-greeter/blob/master/data/lightdm-gtk-greeter.conf
            extraConfig = ''
              # background = Background file to use, either an image path or a color (e.g. #772953)
              font-name = Work Sans 12
              xft-antialias = true
              xft-dpi = 96
              xft-hintstyle = slight
              xft-rgba = rgb

              active-monitor = #cursor
              # position = x y ("50% 50%" by default)  Login window position
              # default-user-image = Image used as default user icon, path or #icon-name
              hide-user-image = false
              round-user-image = false
              highlight-logged-user = true
              panel-position = top
              clock-format = %a, %b %d  %H:%M
            '';
          };
        };
      };
      desktopManager = { xfce.enable = true; };
    };
  };

  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  system.stateVersion = "24.05"; # Did you read the comment?

  users.users."juca" = {
    isNormalUser = true;
    initialPassword = "123";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    ];
    files = [
      "/etc/machine-id"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
  };

  programs.fuse.userAllowOther = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "juca" = import ./home.nix;
    };
  };
}
