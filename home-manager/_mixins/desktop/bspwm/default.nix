{ pkgs, config, lib, ... }@args:
let
  _ = lib.getExe;
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  vars = import ./vars.nix { inherit pkgs config; };
  # thunar-with-plugins = with pkgs.xfce; (thunar.override {
  #   thunarPlugins = [ thunar-volman thunar-archive-plugin thunar-media-tags-plugin ];
  # });
  windowMan = "${_ config.xsession.windowManager.bspwm.package}";

in
{

  imports = [
    ./polybar-everforest.nix
    ../../apps/file-managers/thunar.nix
    # ./polybar-batman.nix
    ./picom.nix
  ];
  config = {
    home =
      {
        # zsh-history-substring-search zsh-syntax-highlighting
        packages = with pkgs; [
          wmname
          sxhkd
          gnome.file-roller
          xfce.xfce4-power-manager
          xorg.xdpyinfo
          xorg.xkill
          xorg.xrandr
          xorg.xsetroot
          xorg.xwininfo
          xorg.xprop
          xorg.xrandr
          mpc-cli
          brightnessctl
          dunst
          feh
          gtk-engine-murrine
          gtk_engines
          # pamixer # Pulseaudio command line mixer
          # nitrogen
          cava
          font-manager
          # libinput-gestures
          lm_sensors
          lxappearance-gtk2
          gparted
          ntfsprogs
          pavucontrol
          udiskie
          # udisks
          blueberry
          # (geany-with-vte.override {
          #   packages = with  pkgs; [
          #     file
          #     gtk3
          #     hicolor-icon-theme
          #     intltool
          #     libintl
          #     which
          #     wrapGAppsHook
          #     pkg-config
          #     automake
          #     autoreconfHook
          #     docutils
          #     geany.all
          #   ];
          # })
          libwebp
          papirus-icon-theme
          playerctl
          imagemagick
          parcellite
          jq
          jgmenu
          maim
          gpick
          physlock
          xclip
          xdg-user-dirs
          xdg-desktop-portal-gtk
          polkit_gnome
          picom
          playerctl
          xclip
          dialog

          ### Theme
          papirus-icon-theme
          papirus-folders
          materia-theme
          gnome3.adwaita-icon-theme

          # Utils

          # fonts
          maple-mono
          font-awesome
          meslo-lgs-nf
          maple-mono-SC-NF
          unstable.sarasa-gothic
        ];

        # sudo apt-get reinstall lxsession;sudo apt install --reinstall lightdm;sudo systemctl enable lightdm

        sessionVariables = {
          "_JAVA_AWT_WM_NONREPARENTING" = "1";
        };

        sessionPath = [
          "$HOME/.local/bin"
          "$HOME/.local/share/applications"
        ];

        file = {
          ".local/share/applications/bspwm.desktop" = {
            text = ''
              [Desktop Entry]
              Name=bspwm
              Comment=Binary space partitioning window manager
              Exec=${windowMan}
              Type=Application
            '';
          };
          # "${config.xdg.configHome}/libinput-gestures.conf".text = ''
          #   gesture swipe right 3 bspc desktop -f next.local
          #   gesture swipe left 3 bspc desktop -f prev.local
          # '';

          ".xinitrc" = {
            executable = true;
            text = ''
              #!/bin/sh

              userresources=$HOME/.Xresources
              usermodmap=$HOME/.Xmodmap
              sysresources=/etc/X11/xinit/.Xresources
              sysmodmap=/etc/X11/xinit/.Xmodmap

              # merge in defaults and keymaps

              if [ -f $sysresources ]; then
                  ${pkgs.xorg.xrdb}/bin/xrdb -merge $sysresources
              fi

              if [ -f $sysmodmap ]; then
                  ${pkgs.xorg.xmodmap}/bin/xmodmap $sysmodmap
              fi

              if [ -f "$userresources" ]; then
                  ${pkgs.xorg.xrdb}/bin/xrdb -merge "$userresources"
              fi

              if [ -f "$usermodmap" ]; then
                  ${pkgs.xorg.xmodmap}/bin/xmodmap "$usermodmap"
              fi

              if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
                eval $(dbus-launch --exit-with-session --sh-syntax)
              fi
              systemctl --user import-environment DISPLAY XAUTHORITY

              if command -v dbus-update-activation-environment > /dev/null 2>&1; then
                dbus-update-activation-environment DISPLAY XAUTHORITY
              fi

              # start some nice programs

              if [ -d /etc/X11/xinit/xinitrc.d ] ; then
               for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
                [ -x "$f" ] && . "$f"
               done
               unset f
              fi

              exec ${windowMan} &
            '';
          };
        };
      };

    dconf.settings = { };
    xsession = {
      enable = true;
      # initExtra = "exec ${windowMan} &";
      windowManager = {
        # command = "exec ${windowMan} &";
        bspwm = {
          enable = true;
          # package = (nixgl pkgs.unstable.bspwm);
          package = nixgl pkgs.bspwm;
          startupPrograms = [
            "pgrep -x sxhkd > /dev/null || sxhkd"
            # "nitrogen --restore"
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            "sleep 2; polybar -q everforest"
            # "thunar --daemon"
            # "${pkgs.flameshot}/bin/flameshot"
            # "${pkgs.feh}/bin/feh --bg-scale ${config.my.settings.wallpaper}"
          ];
          alwaysResetDesktops = true;
          monitors = {
            Virtual-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" ];
            HDMI-1-0 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" ];
            eDP-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" ];
            # bspc monitor eDP-1 -d 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰮯 󰮯
          };
          extraConfigEarly = ''
            wmname LG3D
            # picom
            # pkill picom
            picom -b --legacy-backends --no-use-damage &
            #picom --expiremental-backends --no-use-damage &

            ### Only have workspaces for primary monitor
            export MONITOR=$(xrandr -q | grep primary | cut -d' ' -f1)
            export MONITORS=( $(xrandr -q | grep ' connected' | cut -d' ' -f1) )
            MONITOR=$\{MONITOR:-$\{MONITORS[0]}}

            bspc config remove_disabled_monitors true
            bspc config remove_unplugged_monitors true
          '';
          extraConfig = ''
            ${pkgs.systemd}/bin/systemctl --user start bspwm-session.target

            # ${pkgs.autorandr}/bin/autorandr --change

            ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
            # Wait for the network to be up
            # ${pkgs.libnotify}/bin/notify-send 'Waiting for network...'
            # while ! systemctl is-active --quiet network-online.target; do sleep 1; done
            # notify-send 'Network found.'

            # Set background and top bar
            # ${pkgs.feh}/bin/feh --bg-scale $HOME/.local/share/img/wallpaper/active
          '';
          settings = {
            remove_disabled_monitors = true;
            remove_unplugged_monitors = true;
            pointer_modifier = "mod4";
            pointer_action1 = "move";
            pointer_action2 = "resize_side";
            pointer_action3 = "resize_corner";
            click_to_focus = "button1";
            focus_follows_pointer = true;
            border_width = 2;
            window_gap = 10;
            automatic_scheme = "tiling";
            initial_polarity = "first_child";
            split_ratio = 0.52;
            single_monocle = true;
            borderless_monocle = true;
            gapless_monocle = false;
            paddingless_mono = true;
            normal_border_color = "#343c40"; # "#1E1F29";
            active_border_color = "#DBBC7F";
            focused_border_color = "#DBBC7F"; # "#BD93F9";
            presel_border_color = "#343c40"; #"#FF79C6";
          };

          rules = {
            "chromium" = {
              desktop = "^3";
              focus = true;
            };
            "firefox" = {
              desktop = "^3";
              focus = true;
            };
            "Blueman-manager" = {
              state = "floating";
              center = true;
            };
            "Alacritty" = {
              state = "pseudo_tiled";
              center = true;
            };
            "Alacritty:floating" = {
              state = "floating";
            };
            "join*" = {
              state = "floating";
            };
            "st:floating" = {
              state = "floating";
            };
            "mpv" = {
              # "mplayer2"
              state = "floating";
              # rectangle = "1200x700+360+190";
              # desktop = "^6";
              sticky = true;
            };
            # "Kupfer.py" = {
            #   focus = "on";
            # };
            # "Screenkey" = {
            #   manage = "off";
            # };
            "Pavucontrol" = {
              state = "floating";
            };
          };
        };
      };
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        package = pkgs.solarc-gtk-theme;
        name = "SolArc";
        # name = "zukitre-dark";
        # package = pkgs.zuki-themes;
      };
      # gtk3.extraConfig = {
      #   Settings = ''
      #     gtk-application-prefer-dark-theme=1
      #   '';
      # };
      # gtk4.extraConfig = {
      #   Settings = ''
      #     gtk-application-prefer-dark-theme=1
      #   '';
      # };
    };

    services = {
      sxhkd = {
        enable = true;
        keybindings = import ./sxhkdrc.nix args;
      };
      fusuma = {
        enable = true;
        extraPackages = with pkgs;[ xdo xdotool coreutils xorg.xprop ];
        settings = {
          swipe = {
            "3" = {
              left = {
                # GNOME: Switch to left workspace
                # command = "xdotool key shift+l"; # "xdotool key ctrl+alt+Right";
                command = "bspc desktop -f {prev}.local";
                # left:
                #     command: exec i3 focus left
                # right:
                #     command: exec i3 focus right
                # up:
                #     command: exec i3 focus down
                # down:
              };
              right = {
                # command = "xdotool key shift+h";
                command = "bspc desktop -f {next}.local";
              };
            };
            # "4" = {
            #   left = {
            #     command = "i3-msg 'workspace prev";
            #   };
            #   right = {
            #     command = "i3-msg 'workspace next";
            #   };
          };
        };
      };
    };

    programs = {
      alacritty = {
        enable = true;
        package = nixgl pkgs.alacritty;
        settings = import ../../apps/terminal/alacritty.nix args;
      };
      rofi = import ./rofi.nix args;
      feh = {
        enable = true;
        # package = pkgs.feh;
        # keybindings = "";
        # buttons = "";
      };
    };

    i18n = {
      # glibcLocales = pkgs.glibcLocales.override {
      #   allLocales = false;
      #   locales = [ "en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8" ];
      # };
      inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-rime
        ];
      };
    };

    systemd.user = {
      targets.bspwm-session = {
        Unit = {
          Description = "Bspwm session";
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };

      services.polkit-gnome-authentication-agent-1 = {
        Unit.Description = "polkit-gnome-authentication-agent-1";
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    # systemd.user.services.polkit-agent = {
    #   Unit = {
    #     Description = "launch authentication-agent-1";
    #     After = [ "graphical-session.target" ];
    #     PartOf = [ "graphical-session.target" ];
    #   };
    #   Service = {
    #     Type = "simple";
    #     Restart = "on-failure";
    #     ExecStart = ''
    #       ${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1
    #     '';
    #   };

    #   Install = { WantedBy = [ "graphical-session.target" ]; };
    # };
  };
}
