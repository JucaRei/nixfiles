{ pkgs, config, lib, hostname, ... }@args:
with lib;
let
  _ = lib.getExe;
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  vars = import ./vars.nix { inherit pkgs config hostname; };
  windowMan = "${_ config.xsession.windowManager.bspwm.package}";
  isSystemd = if ("${pkgs.ps}/bin/ps --no-headers -o comm 1" == "systemd") then false else true;
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
  # startPolybar = pkgs.writeShellScriptBin
in
{
  #config.lib.file.mkOutOfStoreSymlink
  imports = [
    ./everforest/polybar-everforest.nix
    ../../apps/file-managers/thunar.nix
    ../../apps/terminal/alacritty.nix
    ./everforest/picom.nix
    ./everforest/dunst.nix
    ./everforest/conky.nix
  ];
  config = {
    home =
      {
        # zsh-history-substring-search zsh-syntax-highlighting
        packages = with pkgs; [
          ### Utils
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

          sxhkd
          gnome.file-roller
          feh # image viewer
          betterlockscreen # lockscreen
          sqlite # database
          usbutils # usb utilities
          xdg-user-dirs # create xdg user dirs
          flameshot # cool utility for taking screen shots
          # pkg-config # a tool for pkgs to find info about other pkgs
          # lxde.lxsession # lightweight session manager
          qgnomeplatform # QPlatformTheme for a better Qt application inclusion in GNOME
          libsForQt5.qtstyleplugin-kvantum # SVG-based Qt5 theme engine plus a config tool and extra theme
          qt5.qttools
          qt6Packages.qtstyleplugin-kvantum
          libsForQt5.qt5ct
          dialog # display dialog boxes from shell
          arandr
          xfce.ristretto # photo viewer
          # notepadqq # notepad++ but for linux
          xfce.xfce4-settings # setting manager
          gnome.pomodoro # pomodor style timer for taking breaks
          # libsForQt5.ark # imo best linux archive manager
          # fluent
          # (nixgl alacritty) # terminal, #show on rofi applications
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
          # lxappearance-gtk2
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
          playerctl
          imagemagick
          parcellite
          rofi
          libnotify

          # utils
          jgmenu
          maim
          gpick
          physlock
          killall
          xclip
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

        shellAliases = {
          is_picom_on = "pgrep -x 'picom' > /dev/null && echo 'on' || echo 'off'";
        };

        # sudo apt-get reinstall lxsession;sudo apt install --reinstall lightdm;sudo systemctl enable lightdm

        sessionVariables = {
          "_JAVA_AWT_WM_NONREPARENTING" = "1";
          EDITOR = "micro";
          BROWSER = "firefox";
          TERMINAL = "alacritty";
          GLFW_IM_MODULE = "ibus";
          #GDK_SCALE = 2;
          #GDK_DPI_SCALE = 0.5;
          #QT_AUTO_SCREEN_SCALE_FACTOR = 1;
          # XCURSOR_SIZE = "16";
          # GTK_USE_PORTAL = "1";
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

          ".config/polybar/openweathermap.txt".text = ''
            3901194171bca9e5e3236048e50eb1a5
          '';
        };

        pointerCursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 16;
          gtk.enable = true;
          x11.enable = true;
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
          startupPrograms =
            let
              random-unsplash = "${pkgs.feh}/bin/feh --bg-scale 'https://source.unsplash.com/random/1920x1080/?nature' --keep-http --output-dir /tmp/";
            in
            [
              "bspc desktop -f ^1"
              "pgrep -x sxhkd > /dev/null || sxhkd"
              # "nitrogen --restore"
              # "lxpolkit" # prompt to enter sudo password daemon
              # "flameshot"
              "${pkgs.polkit_gnome} /libexec/polkit-gnome-authentication-agent-1"
              "sleep 2; polybar -q everforest"
              "sleep3; conky -c ~/.config/conky/Regulus/Regulus.conf"
              "${vars.picom-custom} --config $HOME/.config/picom/picom.conf"
              random-unsplash
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
            eDP1-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
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
            focus_follows_pointer = false;
            top_padding = 2;
            left_padding = 1;
            right_padding = 1;
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
            normal_border_color = "#b8bfe5"; # "#343c40"; # "#1E1F29"
            active_border_color = "#DBBC7F";
            focused_border_color = "#81ae5f"; # "#BD93F9";
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
              follow = true;
            };
            "Thunar" = {
              desktop = "^2";
              follow = true;
            };
            "Lxappearance" = {
              desktop = "^10";
              follow = false;
            };
            "xst" = {
              desktop = "^1";
              follow = true;
            };
            "alacritty" = {
              desktop = "^1";
              follow = true;
            };
            "Bitwarden" = {
              desktop = "^8";
              follow = true;
            };
            "Lutris" = {
              desktop = "^4";
              follow = true;
            };
            "Postman" = {
              desktop = "^9";
              follow = true;
            };
            "Notepadqq" = {
              desktop = "^2";
              follow = true;
            };
            ".gimp-2.10-wrapped_" = {
              desktop = "^5";
              follow = true;
            };
            "BleachBit" = {
              desktop = "^10";
              follow = true;
            };
            "Zathura" = {
              state = "tiled";
            };
            "Clementine" = {
              desktop = "^5";
              follow = true;
            };
            "haruna" = {
              desktop = "^5";
              follow = true;
            };
            "GParted" = {
              desktop = "^10";
              follow = true;
            };
            "Nvidia-settings" = {
              desktop = "^10";
              follow = true;
            };
            "Ristretto" = {
              desktop = "^5";
              follow = true;
            };
            "steam" = {
              desktop = "^4";
              follow = true;
            };
            "Virt-manager" = {
              desktop = "^5";
              follow = true;
            };
            "ark" = {
              desktop = "^7";
              follow = true;
            };
            "Audacity" = {
              desktop = "^5";
              follow = true;
            };
            "bottles" = {
              desktop = "^4";
              follow = true;
            };
            "krita" = {
              desktop = "^5";
              follow = true;
            };
            "Inkscape" = {
              desktop = "^5";
              follow = true;
            };
            "Gnome-pomodoro" = {
              desktop = "^1";
              follow = false;
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
            "GLava" = {
              border = false;
              center = true;
              focus = true;
              follow = false;
              layer = "below";
              locked = true;
              state = "floating";
              stick = true;
            };
            "mpv" = {
              # "mplayer2"
              state = "floating";
              center = true;
              # rectangle = "1200x700+360+190";
              # desktop = "^6";
              # sticky = true;
            };
            # "Kupfer.py" = {
            #   focus = true;
            # };
            # "Screenkey" = {
            #   manage = "off";
            # };
            "Pavucontrol" = {
              state = "floating";
              desktop = "^10";
              follow = true;
            };
          };
        };
      };
    };

    gtk = {
      enable = true;
      gtk2 = {
        configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        # extraConfig = "gtk-theme-name=Yaru-purple-dark\ngtk-icon-theme-name=Papirus-Dark\ngtk-font-name=Fira Sans";
        extraConfig = ''
          gtk-xft-antialias=1
          gtk-xft-hinting=1
          gtk-xft-hintstyle="hintslight"
          gtk-xft-rgba="rgb"
        '';
      }; #Fluent-Dark
      gtk3 = {
        extraConfig = {
          gtk-xft-antialias = 1;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "hintslight";
          gtk-xft-rgba = "rgb";
          gtk-application-prefer-dark-theme = 1;
        };
      };
      gtk4 = {
        # gtk-icon-theme-name = "ePapirus-Dark";
        # gtk-theme-name = "Yaru-purple-dark";
        # gtk-cursor-theme-name = "volantes_cursors";
        # gtk-cursor-theme-size = "24";
        # gtk-font-name = "Fira Sans";
        #   gtk-theme-name = "Fluent-Dark";
        #   gtk-icon-theme-name = "Papirus-Dark";
        #   gtk-cursor-theme-name = "volantes_cursors";
        extraConfig.gtk-application-prefer-dark-theme = 1;
      };
      iconTheme = {
        # name = "ePapirus-Dark";
        # package = pkgs.papirus-icon-theme;
        package = pkgs.catppuccin-papirus-folders;
        name = "Papirus";
      };
      theme = {
        # name = "Fluent-Dark";
        # package = pkgs.fluent;
        # name = "Yaru-purple-dark";
        # package = pkgs.yaru-theme;
        name = "Catppuccin-Frappe-Compact-Pink-Dark";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "pink" ];
          tweaks = [ "rimless" ];
          size = "compact";
          variant = "frappe";
        };
      };
      cursorTheme = {
        name = "volantes_cursors";
        package = pkgs.volantes-cursors;
        size = 24;
      };
      font = {
        # name = "Fira Code";
        # package = pkgs.fira-code;
        name = "Lexend";
        size = 11;
        package = pkgs.lexend;
      };
    };

    qt = {
      enable = true;
      platformTheme = lib.mkForce "qtct";
      style = {
        name = "Catppuccin-Frappe-Dark";
        package = pkgs.catppuccin-kde.override {
          flavour = [ "frappe" ];
          accents = [ "pink" ];
        };
      };
    };

    xdg = {
      configFile = {
        ".Xresources" = lib.mkForce {
          text = ''
            !! urxvt
            URxvt*depth:                   32
            URxvt*.borderless:             1
            URxvt*.buffered:               true
            URxvt*.cursorBlink:            true
            URxvt*.font:                   xft:monospace:pixelsize=12
            URxvt*.internalBorder:         10
            URxvt*.letterSpace:            0
            URxvt*.lineSpace:              0
            URxvt*.loginShell:             false
            URxvt*.matcher.button:         1
            URxvt*.matcher.rend.0:         Uline Bold fg5
            URxvt*.saveLines:              5000
            URxvt*.scrollBar:              false
            URxvt*.underlineColor:         grey
            URxvt.clipboard.autocopy:      true
            URxvt.iso14755:                false
            URxvt.iso14755_52:             false
            URxvt.perl-ext-common:         default,matcher

            !! st
            Xft.antialias:	1
            Xft.hinting:	1
            Xft.autohint:	0
            Xft.hintstyle:	hintslight
            Xft.rgba:	rgb
            Xft.lcdfilter:	lcddefault

            st.font: FiraCode Nerd Font Mono:style=Medium,Regular:pixelsize=21.34:antialias=true

            ! window padding
            st.borderpx: 20

            ! Set to a non-zero value to disable window decorations (titlebar, etc) and go borderless.
            st.borderless:        1

            st.disablebold:         1
            st.disableitalics:         1
            st.disableroman:         1

            ! Amount of lines scrolled
            st.scrollrate:  5

            ! Kerning / character bounding-box height multiplier
            st.chscale:           1.0

            ! Kerning / character bounding-box width multiplier
            st.cwscale:           1.0

            ! Available cursor values: 2 4 6 7 = █ _ | ☃ ( 1 3 5 are blinking versions)
            st.cursorshape:       6

            ! thickness of underline and bar cursors
            st.cursorthickness:   2

            ! 1: render most of the lines/blocks characters without using the font for
            ! perfect alignment between cells (U2500 - U259F except dashes/diagonals).
            ! Bold affects lines thickness if boxdraw_bold is not 0. Italic is ignored.
            ! 0: disable (render all U25XX glyphs normally from the font).
            st.boxdraw: 0

            ! (0|1) boxdraw(bold) enable toggle
            st.boxdraw_bold: 0

            ! braille (U28XX):  1: render as adjacent "pixels",  0: use font
            st.boxdraw_braille: 0

            ! set this to a non-zero value to force window depth
            st.depth: 0

            ! opacity==255 means what terminal will be not transparent, 0 - fully transparent
            ! (float values in range 0 to 1.0 may also be used)
            st.opacity:      0.5

            st.background: #181f21
            st.foreground: #dadada

            ! Black + DarkGrey
            st.color0:  #151515
            st.color8:  #505050

            ! DarkRed + Red
            st.color1:  #ac4142
            st.color9:  #ac4142

            ! DarkGreen + Green
            st.color2:  #7e8d50
            st.color10: #7e8d50

            ! DarkYellow + Yellow
            st.color3:  #e5b566
            st.color11: #e5b566

            ! DarkBlue + Blue
            st.color4:  #6c99ba
            st.color12: #6c99ba

            ! DarkMagenta + Magenta
            st.color5:  #9e4e85
            st.color13: #9e4e85

            ! DarkCyan + Cyan
            st.color6:  #7dd5cf
            st.color14: #7dd5cf

            ! LightGrey + White
            st.color7:  #d0d0d0
            st.color15: #f5f5f5
          '';
        };
        # "Fluent-Dark-kvantum" = {
        #   recursive = true;
        #   target = "Kvantum/Fluent-Dark";
        #   source = ../../config/kvantum/Fluent-Dark;
        # };
        # "kvantum.kvconfig" = {
        #   text = ''
        #     [General]
        #     theme=Fluent-Dark
        #   '';
        #   target = "Kvantum/kvantum.kvconfig";
        # };
        "Kvantum/catppuccin/catppuccin.kvconfig".source = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Frappe-Pink/Catppuccin-Frappe-Pink.kvconfig";
          sha256 = "0pl936nchif2zsgzy4asrlc3gvv4fv2ln2myrqx13r6xra1vkcqs";
        };
        "Kvantum/catppuccin/catppuccin.svg".source = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Frappe-Pink/Catppuccin-Frappe-Pink.svg";
          sha256 = "1b92j0gb65l2pvrf90inskr507a1kwin1zy0grwcsdyjmrm5yjrv";
        };
        "Kvantum/kvantum.kvconfig".text = ''
          [General]
          theme=catppuccin

          [Applications]
          catppuccin=qt5ct, org.qbittorrent.qBittorrent, hyprland-share-picker
        '';
        "jgmenu/jgmenurc".text = ''
          position_mode = pointer
          stay_alive = 0
          tint2_look = 0
          terminal_exec = ${vars.alacritty-custom}
          terminal_args = -e
          menu_width = 160
          menu_padding_top = 5
          menu_padding_right = 5
          menu_padding_bottom = 5
          menu_padding_left = 5
          menu_radius = 8
          menu_border = 0
          menu_halign = left
          sub_hover_action = 1
          item_margin_y = 5
          item_height = 30
          item_padding_x = 8
          item_radius = 6
          item_border = 0
          sep_height = 2
          font = Clarity City Bold 12px
          icon_size = 16
          icon_theme = Papirus-Dark
          arrow_string = 󰄾
          color_menu_border = #ffffff 0
          color_menu_bg = #1a1b26
          color_norm_bg = #ffffff 0
          color_norm_fg = #c0caf5
          color_sel_bg = #222330
          color_sel_fg = #c0caf5
          color_sep_fg = #414868
        '';
        "jgmenu/scripts/menu.txt" = {
          text = ''
            Terminal,${_ vars.alacritty-custom},${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/terminal.svg
            Web Browser,brave --browser,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/internet-web-browser.svg
            File Manager,thunar ,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/org.xfce.thunar.svg

            ^sep()

            Favorites,^checkout(favorites),${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/status/starred.svg

            ^sep()

            Widgets,^checkout(wg),${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/kmenuedit.svg
            BSPWM,^checkout(wm),${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/gnome-windows.svg
            Exit,^checkout(exit),${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-shutdown.svg

            ^tag(favorites)
            Editor,OpenApps --editor,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/standard-notes.svg
            Neovim,OpenApps --nvim,nvim
            # Firefox,OpenApps --browser,brave
            Brave,brave ,brave
            Retroarch,retroarch,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/retroarch.svg

            ^tag(wg)
            User Card,OpenApps --usercard,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-users.svg
            Music Player,OpenApps --player,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/musique.svg
            Power Menu,OpenApps --powermenu,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/status/changes-allow.svg
            Calendar,OpenApps --calendar,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/office-calendar.svg

            ^tag(wm)
            Change Theme,OpenApps --rice,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/colors.svg
            Keybinds,KeybindingsHelp,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/preferences-desktop-keyboard-shortcuts.svg
            Restart WM,bspc wm -r,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-reboot.svg
            Quit,bspc quit,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-log-out.svg

            ^tag(exit)
            Block computer,physlock -d,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/status/changes-prevent.svg
            Reboot,systemctl reboot,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-reboot.svg
            Shutdown,systemctl poweroff,${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps/system-shutdown.svg
          '';
        };
      };
      desktopEntries = {
        rofi-bluetooth = {
          name = "Rofi Bluetooth Manager";
          genericName = "Bluetooth Manager";
          comment = "Bluetooth";
          icon = "bluetooth";
          exec = "${pkgs.rofi-bluetooth}/bin/rofi-bluetooth";
          terminal = false;
          categories = [ "Network" ];
        };
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
          threshold = { swipe = 0.1; };
          interval = { swipe = 0.7; };
          swipe = {
            "3" = {
              left = {
                # GNOME: Switch to left workspace
                command = "xdotool key ${vars.mod}+Right"; # "xdotool key ctrl+alt+Right";
                # command = "${config.xsession.windowManager.bspwm.package}/bin/bspc desktop -f {prev}.local";
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
                command = "xdotool key ${vars.mod}+Left";
                # command = "${config.xsession.windowManager.bspwm.package}/bin/bspc desktop -f {next}.local";
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
      # rofi = import ./everforest/rofi.nix args;
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
