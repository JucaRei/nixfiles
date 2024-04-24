{ pkgs, config, lib, ... }@args:
with lib;
let
  _ = lib.getExe;
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  vars = import ./vars.nix { inherit pkgs config; };
  windowMan = "${_ config.xsession.windowManager.bspwm.package}";
  isSystemd = if ("${pkgs.ps}/bin/ps --no-headers -o comm 1" == "systemd") then false else true;
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
in
{
  #config.lib.file.mkOutOfStoreSymlink
  imports = [
    ./everforest/polybar-everforest.nix
    ../../apps/file-managers/thunar.nix
    # ./polybar-batman.nix
    ./everforest/picom.nix
    ./everforest/dunst.nix
  ];
  config = {
    home =
      {
        # zsh-history-substring-search zsh-syntax-highlighting
        packages = with pkgs; [
          sxhkd
          gnome.file-roller
          feh # image viewer
          betterlockscreen # lockscreen
          xclip
          xdotool
          xorg.xinit
          xorg.libXcomposite
          xorg.libXinerama
          xorg.libxcb
          xorg.xdpyinfo
          xorg.xkill
          xorg.xsetroot
          xorg.xwininfo
          xorg.xrandr
          sqlite # database
          usbutils # usb utilities
          xdg-user-dirs # create xdg user dirs
          picom # compositor
          flameshot # cool utility for taking screen shots
          pkg-config # a tool for pkgs to find info about other pkgs
          lxde.lxsession # lightweight session manager
          qgnomeplatform # QPlatformTheme for a better Qt application inclusion in GNOME
          libsForQt5.qtstyleplugin-kvantum # SVG-based Qt5 theme engine plus a config tool and extra theme
          dialog # display dialog boxes from shell
          arandr
          xfce.ristretto # photo viewer
          qbittorrent # torrent downloader utility
          notepadqq # notepad++ but for linux
          xfce.xfce4-settings # setting manager
          gnome.pomodoro # pomodor style timer for taking breaks
          xfce.exo # this is for xfce shortcuts like open terminal
          libsForQt5.ark # imo best linux archive manager
          (nixgl alacritty) # terminal, #show on rofi applications
          # (nixgl i3lock-color)
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
          pavucontrol
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

          # utils
          jq
          jgmenu
          maim
          gpick
          physlock
          killall
          xclip
          picom
          xclip
          dialog

          # compression
          lzop
          p7zip
          unrar
          zip

          # system
          xdg-utils
          gtk-layer-shell
          gtk3
          xdg-user-dirs
          xdg-desktop-portal-gtk
          udiskie
        ];

        # sudo apt-get reinstall lxsession;sudo apt install --reinstall lightdm;sudo systemctl enable lightdm

        sessionVariables = {
          "_JAVA_AWT_WM_NONREPARENTING" = "1";
          # Try really hard to get QT to respect my GTK theme.
          # GTK_DATA_PREFIX = [ "${config.system.path}" ];
          QT_QPA_PLATFORMTHEME = "gnome";
          QT_STYLE_OVERRIDE = "kvantum";
        };

        sessionPath = [
          "$HOME/.local/bin"
          "$HOME/.local/share/applications"
        ];

        file = {
          ".local/share/applications/bspwm.desktop" = mkIf (!isSystemd) {
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

          ".xinitrc" = mkIf (!isSystemd) {
            executable = true;
            text = ''
              #!${pkgs.stdenv.shell}

              userresources=$HOME/.Xresources
              usermodmap=$HOME/.Xmodmap
              sysresources=/etc/X11/xinit/.Xresources
              sysmodmap=/etc/X11/xinit/.Xmodmap

              # Make sure this is before the 'exec' command or it won't be sourced.
              [ -f /etc/xprofile ] && . /etc/xprofile
              [ -f ~/.xprofile ] && . ~/.xprofile

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

              exec ${pkgs.dbus}/bin/dbus-launch --exit-with-session ${windowMan} &
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
          enable = isSystemd;
          # package = (nixgl pkgs.unstable.bspwm);
          package = if (isGeneric) then (nixgl pkgs.bspwm) else pkgs.bspwm;
          startupPrograms = [
            "bspc desktop -f ^1"
            "pgrep -x sxhkd > /dev/null || sxhkd"
            # "nitrogen --restore"
            # "lxpolkit" # prompt to enter sudo password daemon
            # "flameshot"
            "${pkgs.polkit_gnome} /libexec/polkit-gnome-authentication-agent-1"
            "sleep 2; polybar -q everforest"
            # "tmux new-session -d -s main" # for fast attach to tmux session
            # "tmux new-session -d -s code" # for fast attach to tmux session
            # "thunar --daemon"
            # "${pkgs.flameshot}/bin/flameshot"
            # "${pkgs.feh}/bin/feh --bg-scale ${config.my.settings.wallpaper}"
            # run this last so it doesn't interupt other stuff.
            # "lxappearance" & # Fix cursor not showing on desktop (background)
            # "sleep 3"
            # "pkill lxappearance" # Fix cursor not showing on desktop (background)
          ];
          alwaysResetDesktops = true;
          monitors = {
            Virtual-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
            HDMI-1-0 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
            eDP-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
            # bspc monitor eDP-1 -d 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰮯 󰮯
          };
          extraConfigEarly = ''
            ${pkgs.wmname}/bin/wmname LG3D
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
            top_monocle_padding = 6;
            right_monocle_padding = 4;
            left_monocle_padding = 4;
            bottom_monocle_padding = 2;
            automatic_scheme = "tiling";
            initial_polarity = "first_child";
            split_ratio = 0.52;
            single_monocle = true;
            borderless_monocle = false;
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
            "librewolf" = {
              desktop = "^3";
              follow = "on";
            };
            "Thunar" = {
              desktop = "^2";
              follow = "on";
            };
            "Lxappearance" = {
              desktop = "^10";
              follow = "off";
            };
            "xst" = {
              desktop = "^1";
              follow = "on";
            };
            "alacritty" = {
              desktop = "^1";
              follow = "on";
            };
            "Bitwarden" = {
              desktop = "^8";
              follow = "on";
            };
            "Lutris" = {
              desktop = "^4";
              follow = "on";
            };
            "Postman" = {
              desktop = "^9";
              follow = "on";
            };
            "Notepadqq" = {
              desktop = "^2";
              follow = "on";
            };
            ".gimp-2.10-wrapped_" = {
              desktop = "^5";
              follow = "on";
            };
            "BleachBit" = {
              desktop = "^10";
              follow = "on";
            };
            "Clementine" = {
              desktop = "^5";
              follow = "on";
            };
            "haruna" = {
              desktop = "^5";
              follow = "on";
            };
            "GParted" = {
              desktop = "^10";
              follow = "on";
            };
            "Nvidia-settings" = {
              desktop = "^10";
              follow = "on";
            };
            "Ristretto" = {
              desktop = "^5";
              follow = "on";
            };
            "steam" = {
              desktop = "^4";
              follow = "on";
            };
            "Virt-manager" = {
              desktop = "^5";
              follow = "on";
            };
            "ark" = {
              desktop = "^7";
              follow = "on";
            };
            "Audacity" = {
              desktop = "^5";
              follow = "on";
            };
            "bottles" = {
              desktop = "^4";
              follow = "on";
            };
            "krita" = {
              desktop = "^5";
              follow = "on";
            };
            "Inkscape" = {
              desktop = "^5";
              follow = "on";
            };
            "Gnome-pomodoro" = {
              desktop = "^1";
              follow = "off";
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
              desktop = "^10";
              follow = "on";
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
        # package = pkgs.solarc-gtk-theme;
        # name = "SolArc";
        name = "zukitre-dark";
        package = pkgs.zuki-themes;
      };
      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
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
      # alacritty = {
      #   enable = true;
      #   package = nixgl pkgs.alacritty;
      #   settings = import ../../apps/terminal/alacritty.nix args;
      # };
      rofi = import ./everforest/rofi.nix args;
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
