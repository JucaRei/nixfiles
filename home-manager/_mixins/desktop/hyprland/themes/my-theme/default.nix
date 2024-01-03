{ pkgs, lib, config, hostname, osConfig, inputs, username, ... }:
let
  nixGL = import ../../../../../../lib/nixGL.nix { inherit config pkgs; };

  # mpvpaper-custom = (nixGL pkgs.mpvpaper); # Live wallpaper
  scripts.wl-screenshot = {
    runtimeInputs = [ pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.swayimg ];
    text = ''
      # ideas stolen from https://github.com/emersion/slurp/issues/104#issuecomment-1381110649

      grim - | swayimg --background none --scale real --no-sway --fullscreen --layer - &
      # shellcheck disable=SC2064
      trap "kill $!" EXIT
      grim -t png -g "$(slurp)" - | wl-copy -t image/png
    '';
  };

  random-wall = pkgs.writeShellScriptBin "random-wall" ''
    wall=$(find ~/Pictures/wallpapers -type f -name "*.png" -o -name "*.jpg"| shuf -n 1)
    swww img $wall &
  '';

  # hyprbars-button = rgba($COLOR), $SIZE, $ICON, hyprctl dispatch killactive
  # hyprbars-button = rgba($COLOR), $SIZE, $ICON, hyprctl dispatch fullscreen 1
  # hyprbars-button = rgba($COLOR), $SIZE, $ICON, hyprctl dispatch movetoworkspacesilent special:MinimizedApps

  layout = if hostname == "nitro" then "br" else "us";
  variant = if hostname == "nitro" then "abnt2" else "mac";
  model = if hostname == "nitro" then "pc105" else "pc104";

  grimblast = "${inputs.hyprwm-contrib.packages.${pkgs.system}.grimblast}/bin/grimblast";

  browser = "${pkgs.firefox}";

  # Apps
  filemanager = "${pkgs.xfce.thunar}";

  xdg = pkgs.writeShellScriptBin "xdg" ''
    sleep 1

    # kill all possible running xdg-desktop-portals
    killall xdg-desktop-portal-hyprland
    killall xdg-desktop-portal-gnome
    killall xdg-desktop-portal-kde
    killall xdg-desktop-portal-lxqt
    killall xdg-desktop-portal-wlr
    killall xdg-desktop-portal-gtk
    killall xdg-desktop-portal
    sleep 1

    # start xdg-desktop-portal-hyprland
    ${pkgs.xdg-desktop-portal-hyprland} &
    sleep 2

    # start xdg-desktop-portal
    ${pkgs.xdg-desktop-portal} &
    sleep 1
  '';

  myswaylock = pkgs.writeShellScriptBin "myswaylock" ''
    ${pkgs.swaylock-effects}/bin/swaylock  \
          --screenshots \
          --clock \
          --indicator \
          --indicator-radius 100 \
          --indicator-thickness 7 \
          --effect-blur 7x5 \
          --effect-vignette 0.5:0.5 \
          --ring-color 3b4252 \
          --key-hl-color 880033 \
          --line-color 00000000 \
          --inside-color 00000088 \
          --separator-color 00000000 \
          --grace 2 \
          --fade-in 0.3
  '';

  lockscreentime = pkgs.writeShellScriptBin "lockscreentime" ''
    timeswaylock=600
    timeoff=660
    if [ -f "${pkgs.swayidle}/bin/swayidle" ]; then
        echo "swayidle is installed."
        ${pkgs.swayidle}/bin/swayidle -w timeout $timeswaylock '${myswaylock}/bin/myswaylock -f' timeout $timeoff 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'
    else
        echo "swayidle not installed."
    fi;
  '';

  waybar-reload = pkgs.writeShellScriptBin "waybar-reload" ''
    #!/bin/bash
    killall -SIGUSR1 .waybar-wrapped
    sleep 0.5
    waybar &
  '';

  launch_waybar = pkgs.writeShellScriptBin "launch_waybar" ''
    # killall .waybar-wrapped
    killall ${pkgs.waybar}/bin/waybar
    sleep 0.5
    ${pkgs.waybar}/bin/waybar > /dev/null 2>&1 &
  '';

  terminal = "foot";
  terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    DIR="/home/${username}/Pictures/screenshots/"
    NAME="screenshot_$(date +%d%m%Y_%H%M%S).png"

    option2="Selected area"
    option3="Fullscreen (delay 3 sec)"

    options="$option2\n$option3"

    choice=$(echo -e "$options" | ${pkgs.rofi}/bin/rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 2 -width 30 -p "Take Screenshot")

    case $choice in
        $option2)
            ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -
            notify-send "Screenshot created" "Mode: Selected area"
        ;;
        $option3)
            sleep 3
            ${pkgs.grim}/bin/grim - | ${pkgs.swappy}/bin/swappy -f -
            notify-send "Screenshot created" "Mode: Fullscreen"
        ;;
    esac

  '';

  wallpaper-custom = pkgs.writeShellScriptBin "wallpaper-custom" ''
    # Cache file for holding the current wallpaper
    cache_file="$HOME/.cache/current_wallpaper"
    rasi_file="$HOME/.cache/current_wallpaper.rasi"

    # Create cache file if not exists
    if [ ! -f $cache_file ] ;then
        touch $cache_file
        echo "/home/${username}/Pictures/wallpapers/default.jpg" > "$cache_file"
    fi

    # Create rasi file if not exists
    if [ ! -f $rasi_file ] ;then
        touch $rasi_file
        echo "* { current-image: url(\"/home/${username}/Pictures/wallpapers/default.jpg\", height); }" > "$rasi_file"
    fi

    current_wallpaper=$(cat "$cache_file")

    case $1 in

        # Load wallpaper from .cache of last session
        "init")
            if [ -f $cache_file ]; then
                wal -q -i $current_wallpaper
            else
                wal -q -i /home/${username}/Pictures/wallpapers/
            fi
        ;;

        # Select wallpaper with rofi
        "select")

            selected=$( find "/home/${username}/Pictures/wallpapers" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec basename {} \; | sort -R | while read rfile
            do
                echo -en "$rfile\x00icon\x1f/home/${username}/Pictures/wallpapers/''${rfile}\n"
            done | rofi -dmenu -replace -config ~/.config/rofi/config-wallpaper.rasi)
            if [ ! "$selected" ]; then
                echo "No wallpaper selected"
                exit
            fi
            wal -q -i /home/${username}/Pictures/wallpapers/$selected
        ;;

        # Randomly select wallpaper
        *)
            wal -q -i /home/${username}/Pictures/wallpapers/
        ;;

    esac

    # -----------------------------------------------------
    # Load current pywal color scheme
    # -----------------------------------------------------
    source "$HOME/.cache/wal/colors.sh"
    echo "Wallpaper: $wallpaper"

    # -----------------------------------------------------
    # Write selected wallpaper into .cache files
    # -----------------------------------------------------
    echo "$wallpaper" > "$cache_file"
    echo "* { current-image: url(\"$wallpaper\", height); }" > "$rasi_file"

    # -----------------------------------------------------
    # get wallpaper image name
    # -----------------------------------------------------
    newwall=$(echo $wallpaper | sed "s|/home/${username}/Pictures/wallpapers/||g")

    # -----------------------------------------------------
    # Reload waybar with new colors
    # -----------------------------------------------------
    ${pkgs.waybar}/bin/waybar

    # -----------------------------------------------------
    # Set the new wallpaper
    # -----------------------------------------------------
    transition_type="wipe"
    # transition_type="outer"
    # transition_type="random"

    ${pkgs.swww}/bin/swww img $wallpaper \
        --transition-bezier .43,1.19,1,.4 \
        --transition-fps=60 \
        --transition-type=$transition_type \
        --transition-duration=0.7 \
        --transition-pos "$( hyprctl cursorpos )"

    # -----------------------------------------------------
    # Send notification
    # -----------------------------------------------------
    sleep 1
    notify-send "Colors and Wallpaper updated" "with image $newwall"

    echo "DONE!"

  '';

in
{
  imports = [
    ../../../../apps/terminal/foot.nix
    ./dunst.nix
    ./swaylock.nix
    ./eye-protection.nix
    # ./xresources.nix
    ./rofi.nix
    ./waybar.nix
    ./wlogout
    ./gtk.nix
    # ./scripts
  ];
  wayland = {
    windowManager = {
      hyprland = {
        # "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1 &"

        # exec killall -SIGUSR1 .waybar-wrapped

        # enable = true;
        # systemd.enable = if hostname == "nitro" then true else false;
        settings = {
          exec-once = [
            "${xdg}/bin/xdg"
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "hyprctl setcursor Bibata-Modern-Ice 16"
            "dunst"
            # Load cliphist history
            "wl-paste --watch cliphist store"
            "${launch_waybar}/bin/launch_waybar"
            # "${waybar-reload}/bin/waybar-reload"
            # "hyprctl setcursor Bibata-Modern-Ice 24"
            "swww query || swww init"
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            # "swayidle -w timeout 300 'systemctl suspend' before-sleep '${myswaylock}/bin/myswaylock'"
            "${lockscreentime}/bin/lockscreentime"
            "notify-send 'Hey Junior, Welcome back' &"
            # "mpvpaper -o 'no-audio loop' eDP-1 '/home/${username}/Pictures/wallpapers/fishing-in-the-cyberpunk-city.mp4'"
            # https://moewalls.com/fantasy/samurai-boss-fight-fantasy-dragon-live-wallpaper/
            "${pkgs.wallpaper}/bin/wallpaper-custom"
          ];
          xwayland = {
            force_zero_scaling = true;
          };
          misc = {
            # disable redundant renders
            disable_autoreload = false;
            disable_splash_rendering = true;
            disable_hyprland_logo = true;
            enable_swallow = true;
            animate_manual_resizes = true;
            animate_mouse_windowdragging = true;

            vfr = true;

            # dpms
            mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
            key_press_enables_dpms = true; # enable dpms on keyboard action
            # disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };
          master = {
            new_is_master = true;
          };
        };
        extraConfig = ''
          ###############################
          ### Auto Start Applications ###
          ###############################

          #exec-once = dunst
          #exec-once = waybar
          #exec-once = hyprctl setcursor Bibata-Modern-Ice 24
          #exec-once = swww query || swww init

          #######################
          ### Monitor Configs ###
          #######################

          monitor = eDP-1, 1920x1080@120, 0x0, 1
          monitor = HDMI-A-1, 1920x1080@60, -1920x0, 1

          ##############################
          ### Environments Variables ###
          ##############################

          env = XCURSOR_SIZE,24
          env = WLR_DRM_NO_ATOMIC,1
          env = QT_QPA_PLATFORM,wayland
          env = ozone-platform-hint,auto
          env = enable-features,UseOzonePlatform
          env = ozone-platform,wayland
          # env = GTK_THEME,Adwaita:dark
          # env = WLR_NO_HARDWARE_CURSORS, 1
          # env = WLR_RENDERER_ALLOW_SOFTWARE, 1

          #################################
          ### Keyboard and other inputs ###
          #################################

          input {
            kb_layout = ${layout}
            kb_variant = ${variant}
            kb_model = ${model}
            kb_options =
            kb_rules =

            follow_mouse = 2 #1

            touchpad {
              disable_while_typing = true
              natural_scroll = true
              clickfinger_behavior = true
              tap-and-drag = true
            }

            accel_profile = adaptive
            numlock_by_default = true
            sensitivity = 0.4 # -1.0 - 1.0, 0 means no modification.
          }

          #######################
          ### General Configs ###
          #######################

          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          general {
            gaps_in = 4
            gaps_out = 10
            border_size = 2
            col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
            col.inactive_border = rgba(595959aa)

            layout = dwindle

            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false
            cursor_inactive_timeout = 10
            resize_on_border = true
          }

          ################
          ### Gestures ###
          ################

          Gestures {
            workspace_swipe = true
            workspace_swipe_fingers = 3
          }

          ###########################
          ### Decoration Settings ###
          ###########################

          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          # name: "Rounding More Blur"

          decoration {
            rounding = 10
            blur {
              enabled = true
              size = 10
              passes = 4
              new_optimizations = on
              ignore_opacity = true
              xray = true
              blurls = waybar
            }
            active_opacity = 0.9
            inactive_opacity = 0.7
            fullscreen_opacity = 0.9

            drop_shadow = true
            shadow_range = 30
            shadow_render_power = 3
            col.shadow = 0x66000000
          }

          ################
          ### XWayland ###
          ################

          # Add your additional Hyprland configurations here
          #
          # This is an additional key binding
          # bind = $mainMod CTRL, up, workspace, empty
          #
          # Example for xwayland
          # xwayland {
          #   force_zero_scaling = true
          # }

          ########################
          ### Keybindings Keys ###
          ########################

          # Super Key
          $mainMod = SUPER
          $otherMod = ALT

          #-------------------------------------------#
          # switch between current and last workspace #
          #-------------------------------------------#

          # Applications
          # bind = $otherMod, RETURN, exec, alacritty
          bind = $otherMod, RETURN, exec, foot
          bind = $mainMod, B, exec, firefox

          # Windows
          bind = $otherMod, Q, killactive
          bind = $mainMod, F, fullscreen
          bind = $mainMod, E, exec, thunar
          bind = $mainMod, T, togglefloating

          bind = $mainMod SHIFT, T, exec, hyprctl dispatch workspaceopt allfloat # Float ALL
          bind = $otherMod, P, pseudo
          bind = $mainMod, J, togglesplit
          bind = $mainMod, left, movefocus, l
          bind = $mainMod, right, movefocus, r
          bind = $mainMod, up, movefocus, u
          bind = $mainMod, down, movefocus, d
          bindm = $mainMod, mouse:272, movewindow
          bindm = $mainMod, mouse:273, resizewindow
          bind = $mainMod SHIFT, right, resizeactive, 100 0
          bind = $mainMod SHIFT, left, resizeactive, -100 0
          bind = $mainMod SHIFT, up, resizeactive, 0 -100
          bind = $mainMod SHIFT, down, resizeactive, 0 100

          # Actionsq
          bind = $mainMod, PRINT, exec, ${screenshot}/bin/screenshot
          bind = $mainMod CTRL, Q, exec, wlogout
          bind=$mainMod SHIFT, X, exec, ${myswaylock}/bin/myswaylock
          bind = $mainMod SHIFT, W, exec, $HOME/.config/hypr/scripts/wallpaper.sh
          bind = $mainMod CTRL, W, exec, $HOME/.config/hypr/scripts/wallpaper.sh select
          bind = $mainMod, SPACE, exec, rofi -show drun
          bind = $mainMod CTRL, H, exec, $HOME/.config/hypr/scripts/keybindings.sh
          bind= $mainMod SHIFT, B, exec, killall .waybar-wrapped && waybar & disown
          bind = $mainMod SHIFT, R, exec, hyprctl reload
          bind = $mainMod CTRL, F, exec, ~/dotfiles/scripts/filemanager.sh
          bind = $mainMod CTRL, C, exec, ~/dotfiles/scripts/cliphist.sh
          bind = $mainMod, V, exec, ~/dotfiles/scripts/cliphist.sh
          bind = $mainMod CTRL, T, exec, $HOME/.config/waybar/scripts/themeswitcher.sh
          bind = $mainMod CTRL, S, exec, foot --class dotfiles-floating -e $HOME/.config/hypr/start-settings.sh


          # Workspaces
          bind = $otherMod, 1, workspace, 1
          bind = $otherMod, 2, workspace, 2
          bind = $otherMod, 3, workspace, 3
          bind = $otherMod, 4, workspace, 4
          bind = $otherMod, 5, workspace, 5
          bind = $otherMod, 6, workspace, 6
          bind = $otherMod, 7, workspace, 7
          bind = $otherMod, 8, workspace, 8
          bind = $otherMod, 9, workspace, 9
          bind = $otherMod, 0, workspace, 10
          bind = $otherMod SHIFT, 1, movetoworkspace, 1
          bind = $otherMod SHIFT, 2, movetoworkspace, 2
          bind = $otherMod SHIFT, 3, movetoworkspace, 3
          bind = $otherMod SHIFT, 4, movetoworkspace, 4
          bind = $otherMod SHIFT, 5, movetoworkspace, 5
          bind = $otherMod SHIFT, 6, movetoworkspace, 6
          bind = $otherMod SHIFT, 7, movetoworkspace, 7
          bind = $otherMod SHIFT, 8, movetoworkspace, 8
          bind = $otherMod SHIFT, 9, movetoworkspace, 9
          bind = $otherMod SHIFT, 0, movetoworkspace, 10
          bind = $otherMod, mouse_down, workspace, e+1
          bind = $otherMod, mouse_up, workspace, e-1
          bind = $otherMod CTRL, down, workspace, empty

          # Fn keys
          # bind = , XF86MonBrightnessUp, exec, brightnessctl -q s +10%
          # bind = , XF86MonBrightnessDown, exec, brightnessctl -q s 10%-
          bind = , XF86MonBrightnessUp, exec, brillo -A 5
          bind = , XF86MonBrightnessDown, exec, brillo -U 5
          bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
          bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
          bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
          bind = , XF86AudioPlay, exec, playerctl play-pause
          bind = , XF86AudioPause, exec, playerctl pause
          bind = , XF86AudioNext, exec, playerctl next
          bind = , XF86AudioPrev, exec, playerctl previous
          bind = , XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle
          bind = , XF86Calculator, exec, qalculate-gtk
          bind = , XF86Lock, exec, swaylock
          bind = , XF86Tools, exec, alacritty --class dotfiles-floating -e ~/dotfiles/hypr/settings/settings.sh

          ################################################
          ### Passthrough SUPER KEY to Virtual Machine ###
          ################################################

          #bind = $mainMod, P, submap, passthru
          #submap = passthru
          #bind = SUPER, Escape, submap, reset
          #submap = reset

          ####################
          ### Window rules ###
          ####################

          windowrule = tile,^(Firefox)$
          windowrule = tile,^(Brave-browser)$
          windowrule = tile,^(Chromium)$
          windowrule = float,^(pavucontrol)$
          windowrule = float,^(blueman-manager)$

          windowrulev2 = float,class:(dotfiles-floating)
          windowrulev2 = nomaximizerequest, class:.* # You'll probably like this.
          windowrulev2 = fakefullscreen, class:^(code-url-handler)$

          ####################
          ### Misc Options ###
          ####################

          Misc {
          #   disable_hyprland_logo = false
          #   disable_splash_rendering = false
          #   animate_manual_resizes = true
          #   animate_mouse_windowdragging = true
          default_floating_border pixel 3
          }

          ##################
          ### Animations ###
          ##################

          animations {
            enabled = true
            bezier = wind, 0.05, 0.9, 0.1, 1.05
            bezier = winIn, 0.1, 1.1, 0.1, 1.1
            bezier = winOut, 0.3, -0.3, 0, 1
            bezier = liner, 1, 1, 1, 1
            animation = windows, 1, 6, wind, slide
            animation = windowsIn, 1, 6, winIn, slide
            animation = windowsOut, 1, 5, winOut, slide
            animation = windowsMove, 1, 5, wind, slide
            animation = border, 1, 1, liner
            animation = borderangle, 1, 30, liner, loop
            animation = fade, 1, 10, default
            animation = workspaces, 1, 5, wind
          }
        '';
        # settings = {
        #   bind = [
        #     # Waybar toggle
        #   ];
        # };
        settings = {
          # decoration = {
          #   shadow_offset = "0 5";
          #   "col.shadow" = "rgba(00000099)";
          # };
          #---------------#
          # resize window #
          #---------------#
          bind = [
            "ALT, R, submap, resize"
            ",escape,submap,reset"
            "CTRL SHIFT, left, resizeactive,-15 0"
            "CTRL SHIFT, right, resizeactive,15 0"
            "CTRL SHIFT, up, resizeactive,0 -15"
            "CTRL SHIFT, down, resizeactive,0 15"
            "CTRL SHIFT, l, resizeactive, 15 0"
            "CTRL SHIFT, h, resizeactive,-15 0"
            "CTRL SHIFT, k, resizeactive, 0 -15"
            "CTRL SHIFT, j, resizeactive, 0 15"
          ];
          submap = [ "resize" "reset" ];
          binde = [
            # ",right,resizeactive,15 0"
            # ",left,resizeactive,-15 0"
            # ",up,resizeactive,0 -15"
            # ",down,resizeactive,0 15"
            # ",l,resizeactive,15 0"
            # ",h,resizeactive,-15 0"
            # ",k,resizeactive,0 -15"
            # ",j,resizeactive,0 15"
          ];
        };
      };
    };
  };
  # services.blueman-applet.enable = true;
  home = {
    packages = with pkgs; [
      cantarell-fonts
      libnotify
      swww # wallpaper daemon for wayland, controlled at runtime
      grim # Grab images from a Wayland compositor
      swappy # screenshot resizer
      slurp # Select a region in a Wayland compositor
      figlet # Program for making large letters out of ordinary text
      xautolock # Launch a given program when your X session has been idle for a given time
      blueman
      pkgs.polkit_gnome
      swayidle # Idle management daemon for Wayland
      # papirus-icon-theme
      cliphist # Wayland clipboard history
      qalculate-gtk
      brillo
      random-wall
      # (if hostname != "nitro" then kbdlight else "")
      swaylock-effects
      mpvpaper
      # (nixGL pkgs.mpvpaper) # Live wallpaper
      playerctl
      imv # simple image viewer
      wlogout # Wayland based logout menu
      wlr-randr # An xrandr clone for wlroots compositors
    ] ++ (with pkgs.xfce; [
      xfce4-power-manager
      thunar
      mousepad
      tumbler
    ] ++ (with pkgs.unstable;[
      # papirus-icon-theme
    ]));
    file = {
      ".config/hypr/scripts" = {
        source = ./scripts;
        recursive = true;
        executable = true;
      };
    };
  };

  programs = {
    pywal.enable = true;
  };

  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        icon-theme = "Papirus-Dark";
        cursor-theme = "Bibata-Modern-Ice";
        font-name = "Cantarell 11";
        color-scheme = "prefer-dark";
      };
    };
  };
}
