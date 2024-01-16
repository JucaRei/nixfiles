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

  font-search = pkgs.writeShellScriptBin "font-search" ''
    fc-list \
        | grep -ioE ": [^:]*$1[^:]+:" \
        | sed -E 's/(^: |:)//g' \
        | tr , \\n \
        | sort \
        | uniq
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

  # ${pkgs.unstable.swaylock-effects}/bin/swaylock  \
  myswaylock = pkgs.writeShellScriptBin "myswaylock" ''
    ${pkgs.unstable.swaylock-effects}/bin/swaylock  \
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
  # --ignore-empty-password \
  # --font="Fira Sans Semibold" \
  # --clock \
  # --timestr=%R \
  # --datestr=%a, %e of %B \
  # # Add current screenshot as wallpaper
  # --screenshots \
  # # Add an image as a background
  # # image=~/.cache/current_wallpaper.jpg
  # # Fade in time
  # fade-in=1 \
  # # Effect for background
  # --effect-blur=5x2 \
  # # effect-greyscale
  # # effect-pixelate=5
  # # Show/Hide indicator circle
  # --indicator \
  # # smaller indicator
  # --indicator-radius=200 \
  # # bigger indicator
  # # indicator-radius=300
  # --indicator-thickness=20 \
  # --indicator-caps-lock \
  # # Define all colors
  # --key-hl-color=00000066 \
  # --separator-color=00000000 \
  # --inside-color=00000033 \
  # --inside-clear-color=ffffff00 \
  # --inside-caps-lock-color=ffffff00 \
  # --inside-ver-color=ffffff00 \
  # --inside-wrong-color=ffffff00 \
  # --ring-color=ffffff \
  # --ring-clear-color=ffffff \
  # --ring-caps-lock-color=ffffff \
  # --ring-ver-color=ffffff \
  # --ring-wrong-color=ffffff \
  # --line-color=00000000 \
  # --line-clear-color=ffffffFF \
  # --line-caps-lock-color=ffffffFF \
  # --line-ver-color=ffffffFF \
  # --line-wrong-color=ffffffFF \
  # --text-color=ffffff \
  # --text-clear-color=ffffff \
  # --text-ver-color=ffffff \
  # --text-wrong-color=ffffff \
  # --bs-hl-color=ffffff \
  # --caps-lock-key-hl-color=ffffffFF \
  # --caps-lock-bs-hl-color=ffffffFF \
  # --disable-caps-lock-text \
  # --text-caps-lock-color=ffffff



  lockscreentime = pkgs.writeShellScriptBin "lockscreentime" ''
    timeswaylock=600
    timeoff=660
    if [ -f "${pkgs.unstable.swayidle}/bin/swayidle" ]; then
        echo "swayidle is installed."
        ${pkgs.unstable.swayidle}/bin/swayidle -w timeout $timeswaylock '${myswaylock}/bin/myswaylock -f' timeout $timeoff 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'
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
    killall ${pkgs.unstable.waybar}/bin/waybar
    sleep 0.5
    ${pkgs.unstable.waybar}/bin/waybar > /dev/null 2>&1 &
  '';

  terminal = "foot";
  terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";

  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    DIR="~/Pictures/screenshots/"
    NAME="screenshot_$(date +%d%m%Y_%H%M%S).png"

    option2="Selected area"
    option3="Fullscreen (delay 3 sec)"

    options="$option2\n$option3"

    choice=$(echo -e "$options" | rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 2 -width 30 -p "Take Screenshot")

    case $choice in
        $option2)
            grim -g "$(slurp)" - | swappy -f -
            notify-send "Screenshot created" "Mode: Selected area"
        ;;
        $option3)
            sleep 3
            grim - | swappy -f -
            notify-send "Screenshot created" "Mode: Fullscreen"
        ;;
    esac
  '';

  color-picker = pkgs.writeShellScriptBin "color-picker" ''
    COLOR_OUTPUT=`grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:-`
    COLOR=`echo "$COLOR_OUTPUT" | tail -n1 | awk '{print $3}'`

    echo "$COLOR_OUTPUT"
    echo $COLOR | wl-copy
    echo "Color $COLOR copied to clipboard"
  '';

in
{
  imports = [
    ../../../../apps/terminal/foot.nix
    ../../../../apps/tools/imv.nix
    ../../../../apps/tools/zathura.nix
    ../../../../apps/tools/mailspring.nix
    ./dunst.nix
    # ./swaylock.nix
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
            "xfce4-power-manager"
            # Load cliphist history
            "wl-paste --watch cliphist store"
            "${launch_waybar}/bin/launch_waybar"
            # "${waybar-reload}/bin/waybar-reload"
            # "hyprctl setcursor Bibata-Modern-Ice 24"
            "swww query || swww init"
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            # "swayidle -w timeout 300 'systemctl suspend' before-sleep '${myswaylock}/bin/myswaylock'"
            "${lockscreentime}/bin/lockscreentime"
            # "mpvpaper -o 'no-audio loop' eDP-1 '/home/${username}/Pictures/wallpapers/fishing-in-the-cyberpunk-city.mp4'"
            # https://moewalls.com/fantasy/samurai-boss-fight-fantasy-dragon-live-wallpaper/
            ".config/rofi/scripts/wallpaper.sh"
            "notify-send 'Hey Junior, Welcome back' &"
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

            vrr = 2; # misc:vrr -> Adaptive sync of your monitor. 0 (off), 1 (on), 2 (fullscreen only). Default 0 to avoid white flashes on select hardware.
            vfr = true; # misc:no_vfr -> misc:vfr. bool, heavily recommended to leave at default on. Saves on CPU usage.

            # dpms
            mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
            key_press_enables_dpms = true; # enable dpms on keyboard action
            # disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
          };
          dwindle = {
            no_gaps_when_only = false;
            pseudotile = 0; # enable pseudotiling on dwindle
            special_scale_factor = 0.9;
            split_width_multiplier = 1.0;
            use_active_for_splits = true;
            force_split = 0;
            preserve_split = true;
            default_split_ratio = 1.0;
          };
          master = {
            new_is_master = true;
            orientation = "right";
            special_scale_factor = 0.9;
            no_gaps_when_only = false;
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

          monitor = eDP-1, 1920x1080@120, 1920x1080, 1
          monitor = HDMI-A-1, 1920x1080@60, 0x1080, 1
          # monitor = eDP-1, highres, highrr, auto, 1
          # monitor = HDMI-A-1, highres, highrr, auto, 1
          # monitor = eDP-1, highrr, auto, 1
          # monitor = HDMI-A-1, highrr, auto, 1

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
            gaps_in = 2
            gaps_out = 6
            border_size = 1
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
          # name: "Rounding all Blur"

          # decoration {
          #   rounding = 10
          #   blur {
          #     enabled = true
          #     size = 10
          #     passes = 4
          #     new_optimizations = on
          #     ignore_opacity = true
          #     xray = true
          #     blurls = waybar
          #   }
          #   active_opacity = 0.95
          #   inactive_opacity = 0.84
          #   fullscreen_opacity = 0.95

          #   drop_shadow = true
          #   shadow_range = 30
          #   shadow_render_power = 3
          #   col.shadow = 0x66000000
          # }

          # name: "Rounding"
          # decoration {
          #     rounding = 10
          #     blur {
          #         enabled = true
          #         size = 6
          #         passes = 2
          #         new_optimizations = on
          #         ignore_opacity = true
          #         xray = true
          #         # blurls = waybar
          #     }
          #     active_opacity = 1.0
          #     inactive_opacity = 0.8
          #     fullscreen_opacity = 1.0

          #     drop_shadow = true
          #     shadow_range = 30
          #     shadow_render_power = 3
          #     col.shadow = 0x66000000
          # }

          # name: Default
          # decoration {
          #     rounding = 10
          #     blur {
          #         enabled = true
          #         size = 4
          #         passes = 2
          #         new_optimizations = on
          #         ignore_opacity = true
          #         xray = true
          #         # blurls = waybar
          #     }
          #     active_opacity = 1.0
          #     inactive_opacity = 0.89
          #     fullscreen_opacity = 1.0

          #     drop_shadow = true
          #     shadow_range = 30
          #     shadow_render_power = 3
          #     col.shadow = 0x66000000
          # }

          # name: "Rounding All Blur No Shadows"
          # decoration {
          #     rounding = 10
          #     blur {
          #         enabled = true
          #         size = 12
          #         passes = 4
          #         new_optimizations = on
          #         ignore_opacity = true
          #         xray = true
          #         blurls = waybar
          #     }
          #     active_opacity = 0.9
          #     inactive_opacity = 0.6
          #     fullscreen_opacity = 0.9

          #     drop_shadow = false
          #     shadow_range = 30
          #     shadow_render_power = 3
          #     col.shadow = 0x66000000
          # }

          # name: "Rounding More Blur"
          decoration {
              rounding = 10
              blur {
                  enabled = true
                  size = 12
                  passes = 6
                  new_optimizations = on
                  ignore_opacity = true
                  xray = true
                  # blurls = waybar
              }
              active_opacity = 0.98
              inactive_opacity = 0.86
              fullscreen_opacity = 0.95

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

          ###############################
          ### Load Keybindings config ###
          ###############################

          source = ~/.config/hypr/keybindings.conf

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

            # other one
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

            # default
            # bezier=pace,0.46, 1, 0.29, 0.99
            # bezier=overshot,0.13,0.99,0.29,1.1
            # bezier = md3_decel, 0.05, 0.7, 0.1, 1
            # animation=windowsIn,1,6,md3_decel,slide
            # animation=windowsOut,1,6,md3_decel,slide
            # animation=windowsMove,1,6,md3_decel,slide
            # animation=fade,1,10,md3_decel
            # animation=workspaces,1,7,md3_decel,slide
            # animation=specialWorkspace,1,8,md3_decel,slide
            # animation=border,1,10,md3_decel

            # testing
            # bezier = overshot, 0.05, 0.9, 0.1, 1.05
            # bezier = smoothOut, 0.5, 0, 0.99, 0.99
            # bezier = smoothIn, 0.5, -0.5, 0.68, 1.5
            # animation = windows, 1, 5, overshot, slide
            # animation = windowsOut, 1, 3, smoothOut
            # animation = windowsIn, 1, 3, smoothOut
            # animation = windowsMove, 1, 4, smoothIn, slide
            # animation = border, 1, 5, default
            # animation = fade, 1, 5, smoothIn
            # animation = fadeDim, 1, 5, smoothIn
            # animation = workspaces, 1, 6, default
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
      xarchiver # compressed files using thunar
      # figlet # Program for making large letters out of ordinary text
      slurp # Select a region in a Wayland compositor
      swww # wallpaper daemon for wayland, controlled at runtime
      grim # Grab images from a Wayland compositor
      swappy # screenshot resizer
      swayidle # Idle management daemon for Wayland
      blueman
      font-search
      wdisplays
      polkit_gnome
      # papirus-icon-theme
      cliphist # Wayland clipboard history
      qalculate-gtk
      brillo
      random-wall
      # (if hostname != "nitro" then kbdlight else "")
      mpvpaper
      # (nixGL pkgs.mpvpaper) # Live wallpaper
      playerctl
      # imv # simple image viewer
      wlogout # Wayland based logout menu
      wlr-randr # An xrandr clone for wlroots compositors
      wl-clip-persist
      wl-clipboard
      imagemagick_light
      color-picker
    ] ++ (with pkgs.xfce; [
      xfce4-power-manager
      exo #thunar "open terminal here"
      thunar-archive-plugin
      (thunar.override {
        thunarPlugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-volman
          thunar-media-tags-plugin
        ];
      })
      mousepad
      tumbler
    ] ++ (with pkgs.unstable;[
      # papirus-icon-theme
    ]));
    file = {
      ".config/hypr/keybindings.conf" = {
        text = ''
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
        '';
      };
      ".config/hypr/scripts" = {
        source = ./scripts;
        recursive = true;
        executable = true;
      };
      ".config/rofi/scripts/wallpaper.sh" = {
        source = ./rofi/wallpaper.sh;
        # recursive = true;
        executable = true;
      };
      #######################
      ### Pywal templates ###
      #######################
      ".config/wal/templates/colors-hyprland.conf" = {
        text = ''
          $background = rgb({background.strip})
          $foreground = rgb({foreground.strip})
          $color0 = rgb({color0.strip})
          $color1 = rgb({color1.strip})
          $color2 = rgb({color2.strip})
          $color3 = rgb({color3.strip})
          $color4 = rgb({color4.strip})
          $color5 = rgb({color5.strip})
          $color6 = rgb({color6.strip})
          $color7 = rgb({color7.strip})
          $color8 = rgb({color8.strip})
          $color9 = rgb({color9.strip})
          $color10 = rgb({color10.strip})
          $color11 = rgb({color11.strip})
          $color12 = rgb({color12.strip})
          $color13 = rgb({color13.strip})
          $color14 = rgb({color14.strip})
          $color15 = rgb({color15.strip})
        '';
      };
      ".config/wal/templates/colors-rofi-pywal.rasi" = {
        text = ''
          * {{
              background: rgba(0,0,1,0.5);
              foreground: #FFFFFF;
              color0:     {color0};
              color1:     {color1};
              color2:     {color2};
              color3:     {color3};
              color4:     {color4};
              color5:     {color5};
              color6:     {color6};
              color7:     {color7};
              color8:     {color8};
              color9:     {color9};
              color10:    {color10};
              color11:    {color11};
              color12:    {color12};
              color13:    {color13};
              color14:    {color14};
              color15:    {color15};
          }}
        '';
      };
      ".config/wal/templates/colors-waybar.css" = {
        text = ''
          @define-color foreground {foreground};
          @define-color background {background};
          @define-color cursor {cursor};

          @define-color color0 {color0};
          @define-color color1 {color1};
          @define-color color2 {color2};
          @define-color color3 {color3};
          @define-color color4 {color4};
          @define-color color5 {color5};
          @define-color color6 {color6};
          @define-color color7 {color7};
          @define-color color8 {color8};
          @define-color color9 {color9};
          @define-color color10 {color10};
          @define-color color11 {color11};
          @define-color color12 {color12};
          @define-color color13 {color13};
          @define-color color14 {color14};
          @define-color color15 {color15};
        '';
      };
      ".config/wal/templates/colors-wlogout.css" = {
        text = ''
          @define-color foreground {foreground};
          @define-color background {background};
          @define-color cursor {cursor};

          @define-color color0 {color0};
          @define-color color1 {color1};
          @define-color color2 {color2};
          @define-color color3 {color3};
          @define-color color4 {color4};
          @define-color color5 {color5};
          @define-color color6 {color6};
          @define-color color7 {color7};
          @define-color color8 {color8};
          @define-color color9 {color9};
          @define-color color10 {color10};
          @define-color color11 {color11};
          @define-color color12 {color12};
          @define-color color13 {color13};
          @define-color color14 {color14};
          @define-color color15 {color15};
        '';
      };
      ".config/swappy/config" = {
        text = ''
          [Default]
          save_dir=$HOME/Pictures/screenshots
          save_filename_format=screenshot_%d-%m-%Y_%H:%M:%S.png
          show_panel=false
          line_size=5
          text_size=20
          text_font=sans-serif
          paint_mode=brush
          early_exit=false
          fill_shape=false
        '';
      };
      ".config/Thunar/uca.xml" = {
        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <actions>
            <action>
              <icon>xterm</icon>
              <name>Open Terminal Here</name>
              <unique-id>1612104464586264-1</unique-id>
              <command>foot</command>
              <description></description>
              <patterns>*</patterns>
              <startup-notify/>
              <directories/>
            </action>
            <action>
              <icon>code</icon>
              <name>Open VSCode Here</name>
              <unique-id>1612104464586265-1</unique-id>
              <command>code %f</command>
              <description></description>
              <patterns>*</patterns>
              <startup-notify/>
              <directories/>
            </action>
          </actions>
        '';
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

  services = {
    swayosd = {
      enable = true;
    };
  };

  xfconf.settings = {
    thunar = {
      "/last-show-hidden" = true;
      "/misc-date-style" = "THUNAR_DATE_STYLE_ISO";
      "/misc-middle-click-in-tab" = false;
      "/misc-single-click" = false;
      "/misc-thumbnail-mode" = "THUNAR_THUMBNAIL_MODE_NEVER";
      "/misc-volume-management" = false;
    };
    thunar-volman = {
      "/autobrowse/enabled" = true;
      "/automount-drives/enabled" = true;
      "/automount-media/enabled" = true;
      "/autorun/enabled" = false;
    };
  };
}
