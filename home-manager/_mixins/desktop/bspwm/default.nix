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
            # bspc monitor eDP-1 -d 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰮯 󰮯
          };
          extraConfigEarly = ''
            xsetroot -cursor_name left_ptr

            # picom
            pkill picom
            picom -b &
            #picom --expiremental-backends --no-use-damage &
          '';
          settings = {
            pointer_modifier = "mod4";
            pointer_action1 = "move";
            # pointer_action2 = "resize_side";
            pointer_action2 = "resize_corner";

            border_width = 2;
            window_gap = 10;

            split_ratio = 0.52;
            borderless_monocle = true;
            gapless_monocle = true;

            normal_border_color = "#1E1F29";
            focused_border_color = "#BD93F9";
            presel_border_color = "#FF79C6";
          };

          rules = {
            "Chromium" = {
              desktop = "^2";
            };
            "Blueman-manager" = {
              state = "floating";
              center = true;
            };
            "Alacritty" = {
              state = "pseudo_tiled";
              center = true;
            };
            "Mpv" = {
              # "mplayer2"
              state = "floating";
            };
            # "Kupfer.py" = {
            #   focus = "on";
            # };
            # "Screenkey" = {
            #   manage = "off";
            # };
          };
          # bspc rule -a Chromium desktop='^2'
          # bspc rule -a Blueman-manager state=floating center=true
          # bspc rule -a kitty state=pseudo_tiled center=true
          # bspc rule -a mplayer2 state=floating
          # bspc rule -a Kupfer.py focus=on
          # bspc rule -a Screenkey manage=off
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
        keybindings = import ./sxhkdrc.nix args;
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
