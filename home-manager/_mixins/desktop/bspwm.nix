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
        "flameshot"
        "dunst"
        "nm-applet --indicator"
        "polybar"
        # "sleep 2s;polybar -q main"
      ];
      monitors = {
        Virtual-1 = [
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
}
