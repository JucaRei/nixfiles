{ config, lib, pkgs, username, ... }:
with lib.hm.gvariant;
let
  polybar-user_modules = builtins.readFile (pkgs.substituteAll {
    src = ../config/bspwm/config/polybar/user_modules.ini;
    packages = "${config.home.homeDirectory}/.config/polybar/bin/check-nixos-updates.sh";
    searchpkgs = "${config.home.homeDirectory}/.config/polybar/bin/search-nixos-updates.sh";
    launcher = "${config.home.homeDirectory}/.config/polybar/bin/launcher.sh";
    powermenu = "${config.home.homeDirectory}/.config/rofi/bin/powermenu.sh";
    calendar = "${config.home.homeDirectory}/.config/polybar/bin/popup-calendar.sh";
  });

  polybar-config = pkgs.substituteAll {
    src = ../config/bspwm/config/polybar/config.ini;
    font0 = "DejaVu Sans:size=12;3";
    font1 = "feather:size=12;3"; # dustinlyons/nixpkgs
  };

  polybar-modules = builtins.readFile ../config/bspwm/config/polybar/modules.ini;
  polybar-bars = builtins.readFile ../config/bspwm/config/polybar/bars.ini;
  polybar-colors = builtins.readFile ../config/bspwm/config/polybar/colors.ini;

in
{
  imports = [
    ../config/bspwm2/sxhkd.nix
    # ../config/bspwm/polybar.nix
  ];
  xsession = {
    enable = true;
    numlock.enable = true;
    windowManager.bspwm = {
      enable = true;
      alwaysResetDesktops = true;
      startupPrograms = [
        "sxhkd"
        #       "default_wall"
        # "flameshot"
        "dunst"
        "nm-applet --indicator"
        # "polybar"
        # "sleep 2s;polybar -q main"
      ];
      extraConfig = ''

        ### Color Catpuccin
        bspc config normal_border_color        "#0A0E14"
        bspc config active_border_color        "#1F2430"
        bspc config focused_border_color       "#96CDFB"
        bspc config presel_feedback_color      "#C7C7C7"

        ### Config
        bspc config border_width                2
        bspc config border_radius               0
        bspc config window_gap                  6

        bspc config top_padding                 18
        bspc config bottom_padding              0
        bspc config left_padding                0
        bspc config right_padding               0

        bspc config click_to_focus              true
        bspc config split_ratio                 0.50
        bspc config borderless_monocle          true
        bspc config gapless_monocle             true
        bspc config single_monocle              false
        bspc config paddingless_monocle         true
        bspc config focus_by_distance           true
        bspc config focus_follow_pointer        true
        bspc config history_aware_focus         true
        bspc config remove_disabled_monitors    true
        bspc config merge_overlapping_monitor   true
        bspc config ignore_ewmh_focus           true

        bspc config pointer_modifier            mod4
        bspc config pointer_action1             move
        bspc config pointer_action2             resize_side
        bspc config pointer_action3             resize_corner

      '';
      monitors = {
        Virtual-1 = [
          # monitor = [
          "I"
          "II"
          "III"
          "IV"
          "V"
          "VI"
          "VII"
          "VIII"
        ];
      };
      rules = {
        "mpv" = {
          state = "floating";
          center = true;
        };
        "termfloat" = {
          state = "floating";
          center = true;
        };
        "nemo" = {
          state = "floating";
          center = true;
        };
      };
      #     extraConfigEarly = ''
      #       systemctl --user start bspwm-session.target
      #       systemctl --user start tray.target
      #     '';
    };
  };
  home = {
    packages = with pkgs; [
      feh
      rofi
      rofi-calc
      dunst
      picom
      gtk3
      lf
      papirus-icon-theme
      lxde.lxtask
      pcmanfm
      gnome.file-roller
      xcolor
      xclip
    ];

    pointerCursor = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };

    sessionVariables = {
      # EDITOR = "nvim";
      BROWSER = "firefox";
      # TERMINAL = "kitty";
      GLFW_IM_MODULE = "ibus";
      LIBPROC_HIDE_KERNEL = "true"; # prevent display kernel threads in top
      QT_QPA_PLATFORMTHEME = "gtk3";
    };
    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

  xdg =
    {
      configFile."bspwm/bspwmrc".executable = true;
      dataFile."file-manager/actions/wallpaper.desktop".text = ''
        [Desktop Entry]
        Type=Action
        Name=Set as wallpaper
        Icon=user-desktop
        Profiles=profile-zero;

        [X-Action-Profile profile-zero]
        MimeTypes=image/*;
        Exec=fehbg set %f
        Name=Default profile
        SelectionCount==1
      '';
      configFile."Xresources".text = ''
        *background-clr: #0A0E14
        *background-dim-clr: #1F2430
        *foreground-clr: #B3B1AD
        *foreground-dim-clr: #707880

        *black-clr: #01060E
        *red-clr: #EA6C73
        *green-clr: #91B362
        *yellow-clr: #F9AF4F
        *blue-clr: #53BDFA
        *magenta-clr: #FAE994
        *cyan-clr: #90E1C6
        *white-clr: #C7C7C7
      '';
      # configFile."polybar/config.ini".text = builtins.readFile ../config/bspwm/polybar/config.ini;
      # configFile."sxhkd/sxhkdrc".text = builtins.readFile ../config/bspwm/sxhkdrc;
      # configFile."sxhkd/scripts/bspwm-gap".text = builtins.readFile ../config/bspwm/scripts/bspwm-gap;
      # configFile."sxhkd/scripts/polybar-hide".text = builtins.readFile ../config/bspwm/scripts/polybar-hide;
      # configFile."sxhkd/scripts/sxhkd-help".text = builtins.readFile ../config/bspwm/scripts/sxhkd-help;
      configFile."polybar/bin/popup-calendar.sh" = {
        text = ''
          #!/bin/sh

          DATE="$(/run/current-system/sw/bin/date +"%B %d, %Y")"
          case "$1" in
          --popup)
            /etc/profiles/per-user/${username}/bin/yad --calendar --fixed \
              --posx=1800 --posy=80 --no-buttons --borders=0 --title="yad-calendar" \
              --close-on-unfocus
            ;;
          *)
            echo "$DATE"
          ;;
          esac
        '';
        executable = true;
      };
      configFile."polybar/bin/check-nixos-updates.sh" = {
        text = ''
          #!/bin/sh

          /run/current-system/sw/bin/git -C ~/.dotfiles/nixfiles fetch upstream master
          UPDATES=$(/run/current-system/sw/bin/git -C ~/.dotfiles/nixfiles rev-list origin/master..upstream/master --count 2>/dev/null);
          /run/current-system/sw/bin/echo " $UPDATES"; # Extra space for presentation with icon
          /run/current-system/sw/bin/sleep 1800;
        '';
        executable = true;
      };
      configFile."polybar/bin/search-nixos-updates.sh" = {
        text = ''
          #!/bin/sh

          /etc/profiles/per-user/${username}/bin/firefox --new-window "https://search.nixos.org/packages?channel=23.05&from=0&size=50&sort=relevance&type=packages"
        '';
        executable = true;
      };
      configFile."rofi/colors.rasi".text = builtins.readFile ../config/bspwm/config/rofi/colors.rasi;
      configFile."rofi/confirm.rasi".text = builtins.readFile ../config/bspwm/config/rofi/confirm.rasi;
      configFile."rofi/launcher.rasi".text = builtins.readFile ../config/bspwm/config/rofi/launcher.rasi;
      configFile."rofi/message.rasi".text = builtins.readFile ../config/bspwm/config/rofi/message.rasi;
      configFile."rofi/networkmenu.rasi".text = builtins.readFile ../config/bspwm/config/rofi/networkmenu.rasi;
      configFile."rofi/powermenu.rasi".text = builtins.readFile ../config/bspwm/config/rofi/powermenu.rasi;
      configFile."rofi/styles.rasi".text = builtins.readFile ../config/bspwm/config/rofi/styles.rasi;
      configFile."rofi/bin/powermenu.sh" = {
        text = ''
            #!/bin/sh

                configDir="~/.dotfiles/nixfiles/home-manager/_mixins/config/bspwm/config/rofi"
                uptime=$(uptime -p | sed -e 's/up //g')
                rofi_command="rofi -no-config -theme $configDir/powermenu.rasi"

                # Options
                shutdown=" Shutdown"
                reboot=" Restart"
                lock=" Lock"
                suspend=" Sleep"
                logout=" Logout"

                # Confirmation
                confirm_exit() {
          	      rofi -dmenu\
                        -no-config\
          		      -i\
          		      -no-fixed-num-lines\
          		      -p "Are You Sure? : "\
          		      -theme $configDir/confirm.rasi
                }

                # Message
                msg() {
          	      rofi -no-config -theme "$configDir/message.rasi" -e "Available Options  -  yes / y / no / n"
                }

                # Variable passed to rofi
                options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"
                chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"
                case $chosen in
                    $shutdown)
          		      ans=$(confirm_exit &)
          		      if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
          			      systemctl poweroff
          		      elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
          			      exit 0
                        else
          			      msg
                        fi
                        ;;
                    $reboot)
          		      ans=$(confirm_exit &)
          		      if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
          			      systemctl reboot
          		      elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
          			      exit 0
                        else
          			      msg
                        fi
                        ;;
                    $lock)
                    betterlockscreen -l
                        ;;
                    $suspend)
          		      ans=$(confirm_exit &)
          		      if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
          			      mpc -q pause
          			      amixer set Master mute
          			      systemctl suspend
          		      elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
          			      exit 0
                        else
          			      msg
                        fi
                        ;;
                    $logout)
          		      ans=$(confirm_exit &)
          		      if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
          			      bspc quit
          		      elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
          			      exit 0
                        else
          			      msg
                        fi
                        ;;
                esac
        '';
        executable = true;
      };
    };
  services = {
    udiskie = {
      enable = true;
      automount = true;
      tray = "auto";
    };
    polybar = {
      enable = true;
      config = polybar-config;
      extraConfig = polybar-bars + polybar-colors + polybar-modules + polybar-user_modules;
      package = pkgs.polybarFull;
      script = "polybar main &";
    };
  };
}
