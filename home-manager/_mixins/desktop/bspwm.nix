{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
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
        "polybar"
        # "sleep 2s;polybar -q main"
      ];
      extraConfig = ''

        ### Color Catpuccin
        bspc config normal_border_color        "#1E1E2E"
        bspc config active_border_color        "#1E1E2E"
        bspc config focused_border_color       "#96CDFB"
        bspc config presel_feedback_color      "#96CDFB"

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
          # default = [
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
      #     extraConfig = ''
      #     '';
      #     extraConfigEarly = ''
      #       systemctl --user start bspwm-session.target
      #       systemctl --user start tray.target
      #     '';
    };
  };
  # systemd.user.targets.bspwm-session = {
  #   Unit = {
  #     Description = "bspwm session";
  #     BindsTo = [ "graphical-session.target" ];
  #     Wants = [ "graphical-session-pre.target" "xdg-desktop-autostart.target" ];
  #     After = [ "graphical-session-pre.target" ];
  #   };
  # };
  # programs = {
  #   bash = {
  #     initExtra = ''
  #       if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
  #         exec  startx
  #       fi
  #     '';
  #   };
  #   fish = {
  #     loginShellInit = ''
  #       if status --is-login
  #           if test -z "$DISPLAY" -a $XDG_VTNR = 1
  #               exec startx
  #           end
  #       end
  #     '';
  #   };
  # };
  home = {
    # file = {
    #   ".xinitrc".text = ''
    #     if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
    #       eval $(dbus-launch --exit-with-session --sh-syntax)
    #     fi
    #     systemctl --user import-environment DISPLAY XAUTHORITY
    #     if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    #       dbus-update-activation-environment DISPLAY XAUTHORITY
    #     fi
    #     ${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
    #       Xcursor.theme: Catppuccin-Frappe-Dark
    #     ''}
    #     exec bspwm
    #   '';
    # };

    # file = {
    #   "bspwm/bspwmrc".source = ../config/bspwm/bspwmrc;
    # };
    packages = with pkgs; [
      feh
      rofi
      rofi-calc
      dunst
      picom
      polybarFull
      sxhkd
      gtk3
      lf
      papirus-icon-theme
      lxde.lxtask
      xfce.thunar
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
      configFile."sxhkd/sxhkdrc".text = builtins.readFile ../config/bspwm/sxhkdrc;
      # configFile."sxhkd/scripts/bspwm-gap".text = builtins.readFile ../config/bspwm/scripts/bspwm-gap;
      # configFile."sxhkd/scripts/polybar-hide".text = builtins.readFile ../config/bspwm/scripts/polybar-hide;
      # configFile."sxhkd/scripts/sxhkd-help".text = builtins.readFile ../config/bspwm/scripts/sxhkd-help;
    };
}
