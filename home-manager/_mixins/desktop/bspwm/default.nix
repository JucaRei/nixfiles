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
          extraConfig = ''
            # if [[ $(xrandr -1 | grep 'HDMI-1 connected') ]]; then
            # 	xrandr --output eDP-1 --primary --mode 1920x1080 --rotate normal --output HDMI-1 --mode 1600x900 --rotate normal --right-of eDP-1
            # fi
            bspc monitor eDP-1 -d 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰮯 󰮯

            wmname LG3D

            bspc config pointer_modifier mod4
            bspc config pointer_action1 move
            bspc config pointer_action2 resize_side
            bspc config pointer_action2 resize_corner

            bspc config border_width         2
            bspc config window_gap           10

            bspc config split_ratio          0.52
            bspc config borderless_monocle   true
            bspc config gapless_monocle      true

            bspc config normal_border_color     "#1E1F29"
            bspc config focused_border_color    "#BD93F9"
            bspc config presel_border_color     "#FF79C6"

            bspc rule -a Chromium desktop='^2'
            bspc rule -a Blueman-manager state=floating center=true
            bspc rule -a kitty state=pseudo_tiled center=true
            bspc rule -a mplayer2 state=floating
            bspc rule -a Kupfer.py focus=on
            bspc rule -a Screenkey manage=off
          '';
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
