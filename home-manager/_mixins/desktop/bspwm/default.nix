{ pkgs, config, lib, ... }@args:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
in
{

  config = {
    home =
      let
        gio = pkgs.gnome.gvfs;
      in
      {
        packages = with pkgs; [
          ### Window
          wmname
          (nixgl sxhkd)
          (nixgl dunst)
          (nixgl rofi)
          (nixgl polybar)

          ### Theme
          lxappearance-gtk2

          ### File Manager
          gio # Virtual Filesystem support library
          cifs-utils # Tools for managing Linux CIFS client filesystems

          # Utils
          pamixer # Pulseaudio command line mixer
          imagemagick
          lm_sensors

          # Polkit
          mate.mate-polkit
        ];

        # sudo apt-get reinstall lxsession;sudo apt install --reinstall lightdm;sudo systemctl enable lightdm

        sessionVariables = {
          "_JAVA_AWT_WM_NONREPARENTING" = "1";
          GIO_EXTRA_MODULES = "${gio}/lib/gio/modules";
        };

        sessionPath = [ "$HOME/.local/bin" ];
      };

    dconf.settings = { };
    xsession = {
      enable = true;
      windowManager = {
        bspwm = {
          enable = true;
          package = nixgl pkgs.unstable.bspwm;
          # startupPrograms = [ ];
          alwaysResetDesktops = true;
          monitors = {
            eDP-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" ];
          };
          border = true;
          extraConfig = import ./bspwm.nix { inherit config; } args;
        };
      };
    };

    services = {
      polybar = {
        enable = true;
        package = nixgl pkgs.unstable.polybar;
      };

      sxhkd = {
        enable = true;
        extraConfig = import ./sxhkdrc.nix { inherit config pkgs; } args;
      };
    };

    programs = {
      alacritty = {
        enable = true;
        package = nixgl pkgs.alacritty;
        settings = import ../../apps/terminal/alacritty.nix args;
      };
    };

    systemd.user.services.polkit-agent = {
      Unit = {
        Description = "launch authentication-agent-1";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = ''
          ${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1
        '';
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };

}
