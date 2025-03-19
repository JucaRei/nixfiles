{ config, ... }: {
  imports = [
    ../../../modules/home-manager/programs/terminal
    ../../../modules/home-manager/system/services
  ];
  config = {
    features.nonNixOs = {
      enable = true;
    };

    system = {
      services = {
        ct-podman.enable = true;
      };
    };

    programs = {
      terminal = {
        shells = {
          # bash.enable = true;
          # fish.enable = true;
          zsh.enable = true;
        };
        console = {
          starship.enable = true;
        };
      };
    };

    home = {
      sessionPath = [
        ''XDG_RUNTIME_DIR="/run/user/$UID"''
        ''DBUS_SESSION_BUS_ADDRESS='unix:path=''${XDG_RUNTIME_DIR}/bus''
      ];
      # ''DBUS_SESSION_BUS_ADDRESS='unix:path=''${XDG_RUNTIME_DIR}/bus'' # escape
    };
  };
}

#sudo mount -o remount,size=10G /tmp
# home-switch TMPDIR=/tmp
