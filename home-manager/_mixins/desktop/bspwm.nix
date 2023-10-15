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
      # monitors = {
      #   Virtual-1 = [
      #     "I"
      #     "II"
      #     "III"
      #     "IV"
      #     "V"
      #     "VI"
      #     "VII"
      #     "VIII"
      #   ];
      # };
      #     rules = {
      #       "mpv" = {
      #         state = "floating";
      #         center = true;
      #       };
      #       "termfloat" = {
      #         state = "floating";
      #         center = true;
      #       };
      #       "nemo" = {
      #         state = "floating";
      #         center = true;
      #       };
      #     };
      #     settings = {
      #       pointer_modifier = "mod1";
      #       # top_padding = 40;
      #       border_width = 3;
      #       window_gap = 8;
      #       split_ratio = 0.5;
      #       bordeless_monocle = false;
      #       gapless_monocle = false;
      #       focus_follows_pointer = false;
      #       normal_border_color = "#434c5e";
      #       focused_border_color = "#81A1C1";
      #       urgent_border_color = "#88C0D0";
      #       presel_border_color = "#8FBCBB";
      #       presel_feedback_color = "#B48EAD";
      #     };
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
      xcolor
      xclip
    ];

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
      configFile."bspwm/bspwmrc" = {
        executable = true;
        text = ''
          #!/bin/sh

          bspc monitor -d 1 2 3 4 5

          # set some defaults variables
          BSP_GAP=30
          POLYBAR_HEIGHT=36
          BSP_WINDOW_GAP=20


          # Define a file path to store the variable
          bsp_gap_file="/tmp/BSP_GAP"
          echo $BSP_GAP > $bsp_gap_file

          polybar_height_file="/tmp/POLYBAR_HEIGHT"
          echo $POLYBAR_HEIGHT > $polybar_height_file

          bsp_window_gap_file="/tmp/BSP_WINDOW_GAP"
          echo $BSP_WINDOW_GAP > $bsp_window_gap_file


          #set gaps
          ~/.config/sxhkd/scripts/bspwm-gap --gap

          if [ -f "$HOME/.config/Xresources" ]; then
            xrdb -merge -I"$HOME" "$HOME/.config/Xresources"
          fi

          # get Xresourses colors
          BACKGROUND=$(xrdb -query | grep "background-clr" | cut -f 2)
          BACKGROUND_DIM=$(xrdb -query | grep "background-dim-clr" | cut -f 2)
          FOREGROUND=$(xrdb -query | grep "foreground-clr" | cut -f 2)
          FOREGROUND_DIM=$(xrdb -query | grep "foreground-dim-clr" | cut -f 2)

          BLACK=$(xrdb -query | grep "black-clr" | cut -f 2)
          RED=$(xrdb -query | grep "red-clr" | cut -f 2)
          GREEN=$(xrdb -query | grep "green-clr" | cut -f 2)
          YELLOW=$(xrdb -query | grep "yellow-clr" | cut -f 2)
          BLUE=$(xrdb -query | grep "blue-clr" | cut -f 2)
          MAGENTA=$(xrdb -query | grep "magenta-clr" | cut -f 2)
          CYAN=$(xrdb -query | grep "cyan-clr" | cut -f 2)
          WHITE=$(xrdb -query | grep "white-clr" | cut -f 2)

          #set some bsp configs
          bspc config border_width 		  2
          bspc config split_ratio           0.5
          bspc config borderless_monocle    true
          bspc config gapless_monocle       false

          bspc config focused_border_color  "$BACKGROUND_DIM"
          bspc config normal_border_color   "$BACKGROUND"
          bspc config presel_feedback_color "$WHITE"

          bspc config focus_follows_pointer  false

          # exec ~/.config/bspwm/autostart
        '';
      };
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
    };
  configFile."polybar/config.ini".text = builtins.readFile ../config/bspwm/polybar/config.ini;
}


