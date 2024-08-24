{ lib
, namespace
, config
, ...
}:
let
  inherit (lib.${namespace}) enabled;
in
{
  import = [ ./hardware.nix ];

  excalibur = {
    nix = enabled;

    archetypes = {
      vm = enabled;
    };

    desktop-environment = {
      gnome = {
        enable = true;
      };
    };

    security = {
      doas = enabled;
      keyring = enabled;
    };

    system = {
      boot = {
        enable = true;
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
  system.stateVersion = "21.11"; # Did you read the comment?
}
