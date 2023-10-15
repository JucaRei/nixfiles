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
  configFile."polybar/config.ini".text = ''
    ;==========================================================
    [colors]
    background = ${xrdb:background-clr:#0A0E14}
    background-dim = ${xrdb:background-dim-clr:#45475A}
    foreground = ${xrdb:foreground-clr:#B3B1AD}
    foreground-dim = ${xrdb:foreground-dim-clr:#707880}

    black = ${xrdb:black-clr:#01060E}
    red = ${xrdb:red-clr:#EA6C73}
    green = ${xrdb:green-clr:#91B362}
    yellow = ${xrdb:yellow-clr:#F9AF4F}
    blue = ${xrdb:blue-clr:#53BDFA}
    magenta = ${xrdb:magenta-clr:#FAE994}
    cyan = ${xrdb:cyan-clr:#90E1C6}
    white = ${xrdb:white-clr:#C7C7C7}

    [default]
    module-foreground = ${colors.background}
    module-background = ${colors.white}

    triangle-right = %{T2}█%{T-}
    triangle-left = %{T2}█%{T-}

    #triangle-right = %{T2}%{T-}
    #triangle-left = %{T2}%{T-}

    #triangle-right = %{T2} %{T-}
    #triangle-left = %{T2} %{T-}

    #triangle-right = %{T2}%{T-}
    #triangle-left = %{T2}%{T-}

    #triangle-right = %{T2}█ %{T-}
    #triangle-left = %{T2} █%{T-}

    #triangle-right = %{T2} %{T-}
    #triangle-left = %{T2} %{T-}

    #triangle-right = %{T2}%{T-}
    #triangle-left = %{T2}%{T-}

    #triangle-right = %{T2}█%{T-}
    #triangle-left = %{T2}%{T-}

    #triangle-right = %{T2}%{T-}
    #triangle-left = %{T2}%{T-}

    ;==========================================================
    [settings]
    screenchange-reload = true
    pseudo-transparency = true


    ; Define fallback values used by all module formats
    #format-foreground = 
    #format-background = 
    #format-underline =
    #format-overline =
    #format-spacing =
    #format-padding = 0
    #format-margin =
    #format-offset =

    ;==========================================================
    [bar/main]
    width = 100%
    height = 20

    offset-x = 0
    offset-y = 0

    radius = 0

    dpi = 80
    #background = ${colors.background}
    background = #00000000
    foreground = ${colors.foreground}

    border-size = 8
    border-color = ${self.background}


    ; Under-/overline pixel size and argb color
    ; Individual values can be defined using:
    ; {overline,underline}-size
    ; {overline,underline}-color
    #line-size = 0
    #line-color = ${colors.green}

    #padding-left = 0
    #padding-right = 0

    #module-margin-left = 0
    #module-margin-right = 0

    separator = " "
    #separator-foreground = ${colors.background}
    #separator-background = ${colors.background}

    font-0 = "Hack Nerd Font:size:22;2"
    font-1 = "Hack Nerd font:size=22;4"
    font-2 = "Hack Nerd font:size=22;4"
    font-3 = "Hack Nerd font:size=8;2"


    modules-left = bspwm launchpad date
    modules-center = xwindow
    modules-right = memory wlan eth battery pulseaudio backlight color-picker power-menu
    cursor-click = pointer

    #dim-value = 1.0

    cursor-scroll = ns-resize

    ; Position of the system tray window
    ; If empty or undefined, tray support will be disabled
    ; NOTE: A center aligned tray will cover center aligned modules
    ; Available positions: left center right none
    tray-position = center

    ; If true, the bar will not shift its
    ; contents when the tray changes
    #tray-detached = false

    ; Tray icon max size
    #tray-maxsize = 16

    enable-ipc = true
    wm-restack = bspwm

    ; Prefer fixed center position for the `modules-center` block. 
    ; The center block will stay in the middle of the bar whenever
    ; possible. It can still be pushed around if other blocks need
    ; more space.
    ; When false, the center block is centered in the space between 
    ; the left and right block.
    #fixed-center = false

    ; Put the bar at the bottom of the screen
    #bottom = true

    ; Tell the Window Manager not to configure the window.
    ; Use this to detach the bar if your WM is locking its size/position.
    ; Note: With this most WMs will no longer reserve space for 
    ; the bar and it will overlap other windows. You need to configure
    ; your WM to add a gap where the bar will be placed.



    ;==========================================================
    [module/bspwm]
    type = internal/bspwm

    background = ${colors.foreground-dim}

    pin-workspaces = true
    occupied-scroll = true

    #format = %{T4}<label-state>%{T-} <label-mode>
    format = %{T4}<label-state>%{T-} 
    format-background = ${self.background}

    format-prefix = ${default.triangle-left}
    format-prefix-foreground = ${self.background}
    format-prefix-background = ${root.background}

    format-suffix = ${default.triangle-right}
    format-suffix-background = ${root.background}
    format-suffix-foreground = ${self.background}

    ws-icon-0 = 1;󰈹
    ws-icon-1 = 2;󰅬
    ws-icon-2 = 3;
    ws-icon-3 = 4;󰨞
    ws-icon-4 = 5;
    #ws-icon-default = 
    ws-icon-default = ■


    #label-active = %icon%
    #label-active = ████
    label-active = ██████
    #label-active = ■■■■■■
    label-active-foreground = ${colors.background}
    #label-active-underline= ${colors.red}
    label-active-padding = 1

    #label-occupied = %icon%
    #label-occupied = 
    label-occupied = ■
    label-occupied-foreground = ${colors.background}
    label-occupied-padding = 1

    label-urgent = %name%
    label-urgent-background = ${colors.red}
    label-urgent-padding = 1

    #label-empty = %icon%
    #label-empty = 
    label-empty = □
    label-empty-foreground = ${colors.background}
    label-empty-padding = 1




    label-monocle = m
    label-monocle-foreground = ${colors.background}

    label-tiled = t
    label-tiled-foreground = ${colors.background}

    label-fullscreen = f
    label-fullscreen-foreground = ${colors.background}

    label-floating = y
    label-floating-foreground = ${colors.background}

    label-pseudotiled = P
    label-pseudotiled-foreground = ${colors.background}

    label-locked = l
    label-locked-foreground = ${colors.background}

    label-sticky = s
    label-sticky-foreground = ${colors.background}

    label-private = p
    label-private-foreground = ${colors.background}

    label-marked = M
    label-marked-foreground = ${colors.background}


    ;==========================================================
    [module/date]
    type = internal/date

    background = ${colors.yellow}

    interval = 1

    date = %H:%M 
    date-alt = %A, %d %B %Y

    format = <label>
    format-padding = 0
    label = " 󰥔 %date% "

    format-foreground = ${colors.foreground-dim}
    #format-background = ${self.background}

    #format-prefix = ${default.triangle-left}
    #format-prefix-foreground = ${self.background}
    #format-prefix-background = ${root.background}

    #format-suffix = ${default.triangle-right}
    #format-suffix-foreground = ${self.background}
    #format-suffix-background = ${root.background}


    ;==========================================================
    [module/xwindow]
    type = internal/xwindow
    label = "  %title:0:20:...%  "
    label-foreground = ${colors.foreground-dim}
    #label-background = ${colors.background-dim}

    ;==========================================================
    [module/memory]
    type = internal/memory
    background = ${colors.red}

    interval = 2

    ;format = <label> <bar-used>
    #format = <ramp-used> <label>
    format = %{A1:alacritty -e top:}󰍛 <label> %{A}
    label = %used:2%

    #format-background = ${self.background}
    format-foreground = ${colors.foreground-dim}

    #format-prefix = ${default.triangle-left}
    #format-prefix-foreground = ${self.background}
    #format-prefix-background = ${root.background}
    #
    #format-suffix = ${default.triangle-right}
    #format-suffix-background= ${root.background}
    #format-suffix-foreground= ${self.background}

    format-padding = 0

    ramp-used-0 = 󰫃
    ramp-used-1 = 󰫃
    ramp-used-2 = 󰫃
    ramp-used-3 = 󰫄
    ramp-used-4 = 󰫅
    ramp-used-5 = 󰫆
    ramp-used-6 = 󰫇
    ramp-used-7 = 󰫈


    ;==========================================================
    [network-base]
    type = internal/network
    background = ${colors.cyan}
    interval = 5

    format-connected = <label-connected>

    #format-connected-background = ${self.background}
    format-connected-foreground = ${colors.foreground-dim}

    #format-connected-prefix = ${default.triangle-left}
    #format-connected-prefix-foreground = ${self.background}
    #format-connected-prefix-background = ${root.background}
    #
    #format-connected-suffix = ${default.triangle-right}
    #format-connected-suffix-background= ${root.background}
    #format-connected-suffix-foreground= ${self.background}
    ;format-disconnected = <label-disconnected>
    ;label-disconnected = %{F#F0C674}%ifname%%{F#707880} disconnected

    ;==========================================================
    [module/wlan]
    inherit = network-base
    interface-type = wireless
    label-connected = %{A1:alacritty -e nmtui:} 󰖩 %essid%  %{A}

    ;==========================================================
    [module/eth]
    inherit = network-base
    interface-type = wired
    ;speed-unit = ''

    udspeed-minwidth = 1
    accumulate-stats = true
    #label-connected =  %{A1:alacritty -e nmtui:}󱎔 %ifname%%{A}
    label-connected =  %{A1:alacritty -e nmtui:} 󱘖  %{A}


    ;==========================================================
    [module/battery]
    type = internal/battery
    background = ${colors.green}


    low-at = 15
    full-at = 99
    battery = BAT0
    adapter = ADP1
    ;poll-interval = 5

    format-charging = " <animation-charging> <label-charging>"
    label-charging = %percentage%%

    format-charging-foreground = ${self.background}
    #format-charging-background = ${self.background}

    #format-charging-prefix = ${default.triangle-left}
    #format-charging-prefix-foreground = ${self.background}
    #format-charging-prefix-background = ${root.background}

    #format-charging-suffix = ${default.triangle-right}
    #format-charging-suffix-foreground = ${self.background}
    #format-charging-suffix-background = ${root.background}

    animation-charging-framerate = 100
    animation-charging-0 = 󰢜
    animation-charging-1 = 󰂆
    animation-charging-2 = 󰂇
    animation-charging-3 = 󰂈
    animation-charging-4 = 󰢝
    animation-charging-5 = 󰂉
    animation-charging-6 = 󰢞
    animation-charging-7 = 󰂊
    animation-charging-8 = 󰂋
    animation-charging-9 = 󰂅





    format-discharging = " <ramp-capacity> <label-discharging> "
    label-discharging = %percentage%%

    #format-discharging-background = ${self.background}
    format-discharging-foreground = ${colors.foreground-dim}

    #format-discharging-prefix = ${default.triangle-left}
    #format-discharging-prefix-foreground = ${self.background}
    #format-discharging-prefix-background = ${root.background}

    #format-discharging-suffix = ${default.triangle-right}
    #format-discharging-suffix-foreground = ${self.background}
    #format-discharging-suffix-background = ${root.background}


    ramp-capacity-0 = 󰁺
    ramp-capacity-1 = 󰁻
    ramp-capacity-2 = 󰁼
    ramp-capacity-3 = 󰁽
    ramp-capacity-4 = 󰁾
    ramp-capacity-5 = 󰁿
    ramp-capacity-6 = 󰂀
    ramp-capacity-7 = 󰂁
    ramp-capacity-8 = 󰂂
    ramp-capacity-9 = 󰁹



    format-full = <label-full>
    label-full = 󰂏 %percentage_raw%% 


    format-full-background = ${self.background}
    format-full-foreground = ${colors.background}

    format-full-prefix = ${default.triangle-left}
    format-full-prefix-foreground = ${self.background}
    format-full-prefix-background = ${root.background}

    format-full-suffix = ${default.triangle-right}
    format-full-suffix-foreground = ${self.background}
    format-full-suffix-background = ${root.background}




    format-low = <animation-low> <label-low>
    label-low = %percentage%%



    format-low-background = ${colors.red}
    format-low-foreground = ${colors.background}

    format-low-prefix = ${default.triangle-left}
    format-low-prefix-foreground = ${colors.red}
    format-low-prefix-background = ${root.background}

    format-low-suffix = ${default.triangle-right}
    format-low-suffix-foreground = ${colors.red} 
    format-low-suffix-background = ${root.background}

    animation-low-0 = 󱃍
    animation-low-1 = " "
    animation-low-framerate = 200

    #label-discharging-foreground = ${colors.primary}

    ;==========================================================
    [module/pulseaudio]
    type = internal/pulseaudio
    background = ${colors.background-dim}


    use-ui-max = true
    interval = 5

    format-volume = 󰕾 <label-volume> <ramp-volume>
    label-volume = %percentage%%

    format-volume-background = ${self.background}
    format-volume-foreground = ${colors.foreground}

    format-volume-prefix = ${default.triangle-left}
    format-volume-prefix-foreground = ${self.background}
    format-volume-prefix-background = ${root.background}

    format-volume-suffix = ${default.triangle-right}
    format-volume-suffix-foreground = ${self.background}
    format-volume-suffix-background = ${root.background}

    #ramp-volume-0 = 󰖁
    #ramp-volume-1 = 󰕿
    #ramp-volume-2 = 󰖀
    #ramp-volume-3 = 󰕾

    ramp-volume-9 = %{T4}%{F#B3B1AD}█████████%{F-}%{F#707880}%{F-}%{T-}
    ramp-volume-8 = %{T4}%{F#B3B1AD}████████%{F-}%{F#707880}█%{F-}%{T-}
    ramp-volume-7 = %{T4}%{F#B3B1AD}███████%{F-}%{F#707880}██%{F-}%{T-}
    ramp-volume-6 = %{T4}%{F#B3B1AD}██████%{F-}%{F#707880}███%{F-}%{T-}
    ramp-volume-5 = %{T4}%{F#B3B1AD}█████%{F-}%{F#707880}████%{F-}%{T-}
    ramp-volume-4 = %{T4}%{F#B3B1AD}████%{F-}%{F#707880}█████%{F-}%{T-}
    ramp-volume-3 = %{T4}%{F#B3B1AD}███%{F-}%{F#707880}██████%{F-}%{T-}
    ramp-volume-2 = %{T4}%{F#B3B1AD}██%{F-}%{F#707880}███████%{F-}%{T-}
    ramp-volume-1 = %{T4}%{F#B3B1AD}█%{F-}%{F#707880}████████%{F-}%{T-}
    ramp-volume-0 = %{T4}%{F#B3B1AD}%{F-}%{F#707880}█████████%{F-}%{T-}


    #ramp-volume-9 = %{T4}%{F#B3B1AD}███████%{F-}%{F#707880}%{F-}%{T-}
    #ramp-volume-8 = %{T4}%{F#B3B1AD}███████%{F-}%{F#707880}%{F-}%{T-}
    #ramp-volume-7 = %{T4}%{F#B3B1AD}██████%{F-}%{F#707880}█%{F-}%{T-}
    #ramp-volume-6 = %{T4}%{F#B3B1AD}█████%{F-}%{F#707880}██%{F-}%{T-}
    #ramp-volume-5 = %{T4}%{F#B3B1AD}████%{F-}%{F#707880}███%{F-}%{T-}
    #ramp-volume-4 = %{T4}%{F#B3B1AD}███%{F-}%{F#707880}████%{F-}%{T-}
    #ramp-volume-3 = %{T4}%{F#B3B1AD}██%{F-}%{F#707880}█████%{F-}%{T-}
    #ramp-volume-2 = %{T4}%{F#B3B1AD}█%{F-}%{F#707880}██████%{F-}%{T-}
    #ramp-volume-1 = %{T4}%{F#B3B1AD}%{F-}%{F#707880}███████%{F-}%{T-}
    #ramp-volume-0 = %{T4}%{F#B3B1AD}%{F-}%{F#707880}███████%{F-}%{T-}

    #triangle-right = %{T2}█%{T-}
    #triangle-left = %{T2}█%{T-}


    format-muted = <label-muted>
    label-muted = 󰖁 muted

    format-muted-background = ${self.background}
    format-muted-foreground = ${colors.background}

    format-muted-prefix = ${default.triangle-left}
    format-muted-prefix-foreground = ${self.background}
    format-muted-prefix-background = ${root.background}

    format-muted-suffix = ${default.triangle-right}
    format-muted-suffix-foreground = ${self.background}
    format-muted-suffix-background = ${root.background}



    ;==========================================================
    [module/backlight]
    type = internal/backlight
    card = amdgpu_bl1
    ;use-actual-brightness = false
    ;
    background = ${colors.foreground-dim}

    enable-scroll = true

    format = 󰃠 <label> <ramp>

    format-background = ${self.background}
    format-foreground = ${colors.background}

    format-prefix = ${default.triangle-left}
    format-prefix-foreground = ${self.background}
    format-prefix-background = ${root.background}

    format-suffix = ${default.triangle-right}
    format-suffix-foreground = ${self.background}
    format-suffix-background = ${root.background}


    #ramp-3 = 󰃠
    #ramp-2 = 󰃟
    #ramp-1 = 󰃝
    #ramp-0 = 󰃞

    ramp-9 = %{T4}%{F#0A0E14}█████████%{F-}%{F#45475A}%{F-}%{T-}
    ramp-8 = %{T4}%{F#0A0E14}████████%{F-}%{F#45475A}█%{F-}%{T-}
    ramp-7 = %{T4}%{F#0A0E14}███████%{F-}%{F#45475A}██%{F-}%{T-}
    ramp-6 = %{T4}%{F#0A0E14}██████%{F-}%{F#45475A}███%{F-}%{T-}
    ramp-5 = %{T4}%{F#0A0E14}█████%{F-}%{F#45475A}████%{F-}%{T-}
    ramp-4 = %{T4}%{F#0A0E14}████%{F-}%{F#45475A}█████%{F-}%{T-}
    ramp-3 = %{T4}%{F#0A0E14}███%{F-}%{F#45475A}██████%{F-}%{T-}
    ramp-2 = %{T4}%{F#0A0E14}██%{F-}%{F#45475A}███████%{F-}%{T-}
    ramp-1 = %{T4}%{F#0A0E14}█%{F-}%{F#45475A}████████%{F-}%{T-}
    ramp-0 = %{T4}%{F#0A0E14}%{F-}%{F#45475A}█████████%{F-}%{T-}


    ;==========================================================
    [module/power-menu]
    type = custom/text
    click-left = power-menu

    background = ${colors.background-dim}

    #content = %{T1}   %{T-}
    content = %{T1} ⏻  %{T-}
    content-foreground = ${colors.foreground}
    #content-background = ${self.background}

    #content-prefix = ${default.triangle-left}
    #content-prefix-foreground = ${self.background}
    #content-prefix-background = ${root.background}

    #content-suffix = ${default.triangle-right}
    #content-suffix-background = ${root.background}
    #content-suffix-foreground = ${self.background}

    ;==========================================================
    [module/color-picker]
    type = custom/text
    #click-left = xcolor -s clipboard
    click-left = alacritty -e bspc node --flag hidden=on && xcolor -s clipboard
    background = ${colors.red}

    content = %{T1} 󰙈 %{T-}
    content-foreground = ${colors.foreground-dim}
    #content-background = ${self.background}

    #content-prefix = ${default.triangle-left}
    #content-prefix-foreground = ${self.background}
    #content-prefix-background = ${root.background}

    #content-suffix = ${default.triangle-right}
    #content-suffix-background = ${root.background}
    #content-suffix-foreground = ${self.background}


    ;==========================================================
    [module/launchpad]
    type = custom/text
    click-left = rofi -show drun 

    background = ${colors.blue}

    content = %{T1} 󰍜 %{T-}
    content-foreground = ${colors.foreground-dim}
    #content-background = ${self.background}

    #content-prefix = ${default.triangle-left}
    #content-prefix-foreground = ${self.background}
    #content-prefix-background = ${root.background}

    #content-suffix = ${default.triangle-right}
    #content-suffix-background = ${root.background}
    #content-suffix-foreground = ${self.background}
  '';
}
