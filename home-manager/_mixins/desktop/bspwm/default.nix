{ pkgs, config, lib, hostname, username, ... }@args:
with lib;
let
  _ = lib.getExe; # Get executable path
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; }; # if is non-nixos system
  vars = import ./vars.nix { inherit pkgs config hostname; }; # vars for better check
  windowMan = "${_ config.xsession.windowManager.bspwm.package}"; # get bspwm executable path
  isSystemd = if ("${pkgs.ps}/bin/ps --no-headers -o comm 1" == "systemd") then false else true; # check if is systemd system or not
  # isVirtualMachine = if ("${pkgs.dmidecode}/bin/dmidecode -s system-manufacturer" == "QEMU") then false else true; # check if is running on VM
  isVirtualMachine = if ("${pkgs.uutils-coreutils-noprefix}/bin/cat /sys/devices/virtual/dmi/id/sys_vendor" == "QEMU") then false else true; # check if is running on VM
  isGeneric = if (config.targets.genericLinux.enable) then true else false; # Enables this module when not nixos system

  # random-unsplash = "${pkgs.feh}/bin/feh --bg-scale 'https://source.unsplash.com/random/1920x1080/?nature' --keep-http --output-dir /tmp/"; # random-wall from unsplash
  random-walls = "${pkgs.procps}/bin/watch -n 600 ${pkgs.feh}/bin/feh --randomize --bg-fill '$HOME/Pictures/wallpapers/*'"; # wallpapers from system

  bspc-bin = "${config.xsession.windowManager.bspwm.package}/bin/bspc";
  dual-workspace = pkgs.writeShellScriptBin "dual-workspace" ''
    #!${pkgs.stdenv.shell}

      external=$(${pkgs.xorg.xrandr}/bin/xrandr --query | grep '^HDMI-1-0 connected')
      vm=$(${pkgs.xorg.xrandr}/bin/xrandr --query | grep '^Virtual-1 connected')
      if [[ $HOSTNAME == nitro && $external = *\ connected* ]]; then
              ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
              ${bspc-bin} monitor HDMI-1-0 -d I III V VII IX
              ${bspc-bin} monitor eDP-1 -d II IV VI VIII X
      elif [[ $HOSTNAME == anubis && $vm = *\ connected* ]]; then
              ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --primary --mode 1920x1080
              ${bspc-bin} monitor -d I II III IV V VI VII VIII IX X
      elif  [[ $HOSTNAME == anubis && $external = *\ connected* ]]; then
              ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary --mode 1366x768 --pos 1920x0 --rotate normal --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal
              ${bspc-bin} monitor HDMI-1-0 -d I III V VII IX
              ${bspc-bin} monitor eDP-1 -d II IV VI VIII X
      else
              ${bspc-bin} monitor -d I II III IV V VI VII VIII IX X
      fi
  '';

  startUP =
    if (isVirtualMachine) then
      [
        "bspc desktop -f ^1"
        "pgrep -x sxhkd > /dev/null || sxhkd"
        "sleep 1; exec --no-startup-id ${pkgs.lxde.lxsession}/bin/lxpolkit"
        "sleep 2; polybar -q everforest"
        "sleep3; conky -c $HOME/.config/conky/Regulus/Regulus.conf"
        random-walls
        "thunar --daemon"
      ] else [
      "bspc desktop -f ^1"
      "pgrep -x sxhkd > /dev/null || sxhkd"
      # "nitrogen --restore"
      # "flameshot"
      # "${pkgs.lxde.lxsession}/bin/lxsession"
      # "sleep 1; exec --no-startup-id ${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1"
      "sleep 1; exec --no-startup-id ${pkgs.lxde.lxsession}/bin/lxpolkit"
      # "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      "sleep 2; polybar -q everforest"
      # "${pkgs.systemdMinimal}/bin/systemctl --user start lxpolkit"
      "sleep3; conky -c $HOME/.config/conky/Regulus/Regulus.conf"
      "sleep 2; ${vars.picom-custom} --config $HOME/.config/picom/picom.conf"
      random-walls
      # "tmux new-session -d -s main" # for fast attach to tmux session
      # "tmux new-session -d -s code" # for fast attach to tmux session
      "thunar --daemon"
      # "${pkgs.feh}/bin/feh --bg-scale ${config.my.settings.wallpaper}"
      # run this last so it doesn't interupt other stuff.
      # "lxappearance" & # Fix cursor not showing on desktop (background)
      # "sleep 3"
      # "pkill lxappearance" # Fix cursor not showing on desktop (background)
    ];
in
{
  #config.lib.file.mkOutOfStoreSymlink
  imports = [
    ./everforest/polybar-everforest.nix
    ../../apps/file-managers/thunar.nix
    ../../apps/terminal/alacritty.nix
    ../../apps/documents/zathura.nix # pdf
    ./everforest/rofi.nix
    ./everforest/picom.nix
    ./everforest/dunst.nix
    ./everforest/conky.nix
  ];
  config = {
    home = {
      packages = with pkgs; [
        ### Utils
        xorg.xinit
        xorg.libXcomposite
        xorg.libXinerama
        xorg.xprop
        xorg.libxcb
        xorg.xdpyinfo
        xorg.xkill
        xorg.xsetroot
        xorg.xwininfo
        xorg.xrandr
        xclip
        bc

        # dconf
        # gnome.dconf-editor

        feh # image viewer
        usbutils # usb utilities
        # flameshot # cool utility for taking screen shots
        qgnomeplatform # QPlatformTheme for a better Qt application inclusion in GNOME
        libsForQt5.qtstyleplugin-kvantum # SVG-based Qt5 theme engine plus a config tool and extra theme
        qt5.qttools
        qt6Packages.qtstyleplugin-kvantum
        libsForQt5.qt5ct
        dialog # display dialog boxes from shell
        # xfce.ristretto # photo viewer
        # gnome.pomodoro # pomodor style timer for taking breaks
        gtk-engine-murrine
        gtk_engines
        cava
        # lxde.lxmenu-data # required to discover applications
        # lxde.lxsession # just needed for lxpolkit (an authentication agent)
        font-manager
        lm_sensors
        lxappearance-gtk2
        pavucontrol
        libwebp
        playerctl
        imagemagick

        # utils
        jgmenu
        killall
        dialog
        at-spi2-atk

        # system
        xdg-utils
        # gtk-layer-shell
        # gnome.gnome-keyring
        # gtk3
        xdg-user-dirs # create xdg user dirs
        xdg-desktop-portal-gtk
      ];

      shellAliases = {
        is_picom_on = "pgrep -x 'picom' > /dev/null && echo 'on' || echo 'off'";
      };

      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        EDITOR = "micro";
        TERMINAL = "alacritty";
        GLFW_IM_MODULE = "ibus";
        TERM = "xterm-256color";
        QT_STYLE_OVERRIDE = mkDefault ""; # fix qt-override
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

            # ↓ https://nixos.wiki/wiki/Using_X_without_a_Display_Manager
            if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
              eval $(${pkgs.dbus}/bin/dbus-launch --exit-with-session --sh-syntax)
            fi
            ${pkgs.systemdMinimal}/bin/systemctl --user import-environment DISPLAY XAUTHORITY

            if command -v ${pkgs.dbus}/bin/dbus-update-activation-environment > /dev/null 2>&1; then
              ${pkgs.dbus}/bin/dbus-update-activation-environment DISPLAY XAUTHORITY
            fi

            # start some nice programs

            if [ -d /etc/X11/xinit/xinitrc.d ] ; then
             for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
              [ -x "$f" ] && . "$f"
             done
             unset f
            fi

            eval "$(gnome-keyring-daemon --start)"
            export SSH_AUTH_SOCK
            ${pkgs.dbus}/bin/dbus-update-activation-environment DISPLAY XAUTHORITY

            # exec ${pkgs.dbus}/bin/dbus-launch --autolaunch=$(cat /var/lib/dbus/machine-id) bspwm
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
        size = 22;
        gtk.enable = true;
        x11.enable = true;
      };
    };

    xsession = with builtins; {
      enable = true;
      # initExtra = "exec ${windowMan} &";
      numlock.enable = if (hostname == "nitro") then true else false;
      windowManager = {
        # command = "exec ${windowMan} &";
        bspwm = {
          enable = isSystemd;
          # package = (nixgl pkgs.unstable.bspwm);
          package = if (isGeneric) then (nixgl pkgs.bspwm) else pkgs.bspwm;
          startupPrograms = startUP;
          alwaysResetDesktops = true;
          # monitors = {
          #   Virtual-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
          #   HDMI-1-0 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
          #   eDP-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
          #   eDP1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
          #   eDP1-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
          #   # bspc monitor eDP-1 -d 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰮯 󰮯
          # };
          extraConfigEarly = ''
            ${pkgs.wmname}/bin/wmname LG3D

            bspc config remove_disabled_monitors true
            bspc config remove_unplugged_monitors true
            ${dual-workspace}/bin/dual-workspace
          '';
          extraConfig = ''
            ${pkgs.systemd}/bin/systemctl --user start bspwm-session.target
            ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
          '';
          settings = {
            remove_disabled_monitors = true;
            remove_unplugged_monitors = true;
            pointer_modifier = "mod1";
            pointer_action1 = "move"; # Move floating windows
            # Resize floating windows
            pointer_action2 = "resize_side";
            pointer_action3 = "resize_corner";
            click_to_focus = "button1";
            focus_follows_pointer = false;
            top_padding = 2;
            left_padding = 1;
            right_padding = 1;
            border_width = 2;
            window_gap = 4;
            top_monocle_padding = 2;
            right_monocle_padding = 2;
            left_monocle_padding = 2;
            bottom_monocle_padding = 2;
            automatic_scheme = "tiling";
            initial_polarity = "first_child";
            split_ratio = 0.50;
            single_monocle = true;
            borderless_monocle = true;
            gapless_monocle = false;
            paddingless_mono = true;
            normal_border_color = "#b8bfe5"; # "#343c40"; # "#1E1F29"
            active_border_color = "#DBBC7F";
            focused_border_color = "#81ae5f"; # "#BD93F9";
            presel_border_color = "#343c40"; #"#FF79C6";
          };

          rules = {
            ### browser ###
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
              desktop = "^5";
              follow = true;
            };
            "Thorium-browser" = {
              desktop = "^3";
              follow = true;
            };
            "Lxappearance" = {
              desktop = "^10";
              follow = false;
            };
            ### terminal ###
            "xst" = {
              desktop = "^1";
              follow = true;
            };
            "Alacritty" = {
              # desktop = "^1";
              follow = true;
              state = "floating";
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
            "Guvcview" = {
              desktop = "^9";
              follow = true;
              state = "floating";
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
              state = "floating";
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
            # "Alacritty" = {
            #   state = "pseudo_tiled";
            #   center = true;
            # };
            "Engrampa" = {
              state = "floating";
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
              state = "floating";
              center = true;
              # rectangle = "1200x700+360+190";
              # desktop = "^6";
              # sticky = true;
            };
            "Pavucontrol" = {
              state = "floating";
              desktop = "^10";
              follow = true;
            };
            "ZapZap" = {
              state = "floating";
              desktop = "^9";
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
        extraConfig = ''
          gtk-xft-antialias=1
          gtk-xft-hinting=1
          gtk-xft-hintstyle="hintslight"
          gtk-xft-rgba="rgb"
        '';
      }; #Fluent-Dark
      gtk3 = {
        extraConfig = {
          gtk-xft-rgba = "rgb";
          gtk-button-images = 1;
          gtk-menu-images = 1;
          gtk-enable-event-sounds = 1;
          gtk-enable-input-feedback-sounds = 1;
          gtk-xft-antialias = 1;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "hintfull"; #"hintslight";
          gtk-cursor-blink = true;
          gtk-recent-files-limit = 20;
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
        # Catppuccin
        name = "Catppuccin-Frappe-Compact-Pink-Dark";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "pink" ];
          tweaks = [ "rimless" ];
          size = "compact";
          variant = "frappe";
        };

        # name = "Tokyonight-Dark-BL";
        # package = pkgs.tokyo-night-gtk;
      };
      cursorTheme = {
        # name = "volantes_cursors";
        # package = pkgs.volantes-cursors;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 22;
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
            Firefox,firefox ,firefox
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
        package = pkgs.sxhkd;
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
      gnome-keyring = {
        enable = true;
        # I use gpg-agent for ssh and gpg, so only use it for secrets
        components = [ "secrets" ];
      };
    };

    programs = {
      # rofi = import ./everforest/rofi.nix args;
      feh = {
        enable = true;
        # package = pkgs.feh;
        # keybindings = "";
        # buttons = "";
      };
    };

    systemd.user = {
      targets.bspwm-session = {
        Unit = {
          Description = "Bspwm Session";
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };
    };
  };
}
