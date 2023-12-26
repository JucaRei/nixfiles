{ pkgs, lib, config, hostname, ... }:
let
  scripts.wl-screenshot = {
    runtimeInputs = [ pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.swayimg ];
    text = ''
      # ideas stolen from https://github.com/emersion/slurp/issues/104#issuecomment-1381110649

      grim - | swayimg --background none --scale real --no-sway --fullscreen --layer - &
      # shellcheck disable=SC2064
      trap "kill $!" EXIT
      grim -t png -g "$(slurp)" - | wl-copy -t image/png
    '';

    layout = if hostname == "nitro" then "br" else "us";
    variant = if hostname == "nitro" then "abnt2" else "mac";
    model = if hostname == "nitro" then "pc105" else "pc104";

    browser = "${pkgs.firefox}";

    # Apps
    filemanager = "${pkgs.xfce.thunar}";
  };
in
{
  imports = [
    ./dunst.nix
    ./swaylock.nix
    ./xresources.nix
    ./rofi.nix
  ];
  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        systemd.enable = if hostname == "nitro" then true else false;
        extraConfig = ''
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
          # env = GTK_THEME,Adwaita:dark
          # env = WLR_NO_HARDWARE_CURSORS, 1
          # env = WLR_RENDERER_ALLOW_SOFTWARE, 1

          #################################
          ### Keyboard and other inputs ###
          #################################

          input {
            kb_layout = $\{layout}
            kb_variant = $\{variant}
            kb_model = $\{model}
            kb_options =
            kb_rules =

            follow_mouse = 2 #1

            touchpad {
              disable_while_typing = true
              natural_scroll = true
              clickfinger_behavior = true
              tap-and-drag = true
            }

            numlock_by_default = true
            sensitivity = 0.3 # -1.0 - 1.0, 0 means no modification.
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

          ###########################
          ### Decoration Settings ###
          ###########################

          # See https://wiki.hyprland.org/Configuring/Variables/ for more
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
            active_opacity = 1.0
            inactive_opacity = 0.6
            fullscreen_opacity = 1.0

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
          $mainMod = ALT
          $otherMod = SUPER

          # Applications
          bind = $mainMod, RETURN, exec, alacritty
          #bind = $mainMod, B, exec, $\{browser}

          # Windows
          bind = $mainMod, Q, killactive
          bind = $mainMod, F, fullscreen
          bind = $mainMod, E, exec, $\{filemanager}
          bind = $mainMod, T, togglefloating
          bind = $mainMod SHIFT, T, exec, ~/dotfiles/hypr/scripts/toggleallfloat.sh
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

          # Actions
          bind = $mainMod, PRINT, exec, $HOME/.config/hypr/scripts/screenshot.sh
          bind = $mainMod CTRL, Q, exec, wlogout
          bind = $mainMod SHIFT, W, exec, $HOME/.config/hypr/scripts/wallpaper.sh
          bind = $mainMod CTRL, W, exec, $HOME/.config/hypr/scripts/wallpaper.sh select
          bind = $mainMod CTRL, RETURN, exec, rofi -show drun
          bind = $mainMod CTRL, H, exec, $HOME/.config/hypr/scripts/keybindings.sh
          bind = $mainMod SHIFT, B, exec, ~/dotfiles/waybar/launch.sh
          bind = $mainMod SHIFT, R, exec, $HOME/.config/hypr/scripts/loadconfig.sh
          bind = $mainMod CTRL, F, exec, ~/dotfiles/scripts/filemanager.sh
          bind = $mainMod CTRL, C, exec, ~/dotfiles/scripts/cliphist.sh
          bind = $mainMod, V, exec, ~/dotfiles/scripts/cliphist.sh
          bind = $mainMod CTRL, T, exec, $HOME/.config/waybar/scripts/themeswitcher.sh
          bind = $mainMod CTRL, S, exec, alacritty --class dotfiles-floating -e $HOME/.config/hypr/start-settings.sh

          # Workspaces
          bind = $mainMod, 1, workspace, 1
          bind = $mainMod, 2, workspace, 2
          bind = $mainMod, 3, workspace, 3
          bind = $mainMod, 4, workspace, 4
          bind = $mainMod, 5, workspace, 5
          bind = $mainMod, 6, workspace, 6
          bind = $mainMod, 7, workspace, 7
          bind = $mainMod, 8, workspace, 8
          bind = $mainMod, 9, workspace, 9
          bind = $mainMod, 0, workspace, 10
          bind = $mainMod SHIFT, 1, movetoworkspace, 1
          bind = $mainMod SHIFT, 2, movetoworkspace, 2
          bind = $mainMod SHIFT, 3, movetoworkspace, 3
          bind = $mainMod SHIFT, 4, movetoworkspace, 4
          bind = $mainMod SHIFT, 5, movetoworkspace, 5
          bind = $mainMod SHIFT, 6, movetoworkspace, 6
          bind = $mainMod SHIFT, 7, movetoworkspace, 7
          bind = $mainMod SHIFT, 8, movetoworkspace, 8
          bind = $mainMod SHIFT, 9, movetoworkspace, 9
          bind = $mainMod SHIFT, 0, movetoworkspace, 10
          bind = $mainMod, mouse_down, workspace, e+1
          bind = $mainMod, mouse_up, workspace, e-1
          bind = $mainMod CTRL, down, workspace, empty

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

          # Passthrough SUPER KEY to Virtual Machine
          bind = $mainMod, P, submap, passthru
          submap = passthru
          bind = SUPER, Escape, submap, reset
          submap = reset
        '';
      };
    };
  };
}
