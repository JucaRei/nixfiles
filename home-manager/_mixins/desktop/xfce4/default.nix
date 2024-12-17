{ config, pkgs, lib, ... }: {
  config = {
    desktop.apps = {
      file-managers = {
        thunar.enable = true;
      };
    };

    home = {
      packages = with pkgs.xfce // pkgs // pkgs.mate // pkgs.xorg // pkgs.gnome; [
        elementary-xfce-icon-theme
        gnome-keyring
        gparted
        galculator
        orage
        (writeShellApplication {
          name = "xfce4-panel-toggle";
          runtimeInputs = [ xfce.xfconf ];
          text = ''
            for num in {0,1}
            do
              current=$(xfconf-query -c xfce4-panel -p /panels/panel-"$num"/autohide-behavior)
              if [[ current -eq 1 ]]; then next=0; else next=1; fi
              xfconf-query -c xfce4-panel -p /panels/panel-"$num"/autohide-behavior -s $next
            done
          '';
        })
      ];
    };
  };
}
