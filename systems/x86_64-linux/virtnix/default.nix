{
  lib,
  namespace,
  config,
  ...
}:
let
  inherit (lib.${namespace}) enabled disabled;
  inherit (lib) mkForce;
in
{
  imports = [ ./hardware.nix ];

  excalibur = {
    nix = enabled;

    archetypes = {
      # vm = enabled;
      workstation = enabled;
    };

    programs = {
      desktop-environments = {
        gnome = {
          enable = true;
        };
      };
      graphical = {
        apps = {
          # _1password = mkForce disabled;
        };
      };
    };

    security = {
      doas = enabled;
      keyring = enabled;
    };

    system = {
      boot = {
        enable = true;
        efi = true;
        # systemd-boot = true;
        grub = true;
        plymouth = true;
      };

      fonts = enabled;
      locale = enabled;
      networking = enabled;
      time = enabled;
    };

    services = {
      samba = {
        enable = true;
        shares = {
          # Application data folder
          appData = {
            browseable = true;
            comment = "Application Data folder";
            only-owner-editable = true;
            path = "/home/${config.excalibur.user.name}/.config/";
            public = false;
            read-only = false;
          };

          # Data folder
          data = {
            browseable = true;
            comment = "Data folder";
            only-owner-editable = true;
            path = "/home/${config.excalibur.user.name}/.local/share/";
            public = false;
            read-only = false;
          };

          # Virtual Machines folder
          vms = {
            browseable = true;
            comment = "Virtual Machines folder";
            only-owner-editable = true;
            path = "/home/${config.excalibur.user.name}/vms/";
            public = false;
            read-only = false;
          };

          # ISO images folder
          isos = {
            browseable = true;
            comment = "ISO Images folder";
            only-owner-editable = true;
            path = "/home/${config.excalibur.user.name}/isos/";
            public = false;
            read-only = false;
          };
        };
      };
    };
  };
  system.stateVersion = "24.05"; # Did you read the comment?
  systemd = {
    extraConfig = ''
      DefaultCPUAccounting=yes
      DefaultMemoryAccounting=yes
      DefaultIOAccounting=yes
    '';
    user.extraConfig = ''
      DefaultCPUAccounting=yes
      DefaultMemoryAccounting=yes
      DefaultIOAccounting=yes
    '';
    services."user@".serviceConfig.Delegate = true;
  };
  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 20;
    IOWeight = 20;
  };
}

# sudo mount -o remount,size=10G /nix/.rw-store
# sudo mount -o remount,size=5G /tmp/
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disks.nix
