{ config
, pkgs
, lib
, ...
}:
with lib.hm.gvariant; {
  home = {
    packages = with pkgs; [
      elementary-xfce-icon-theme
      gparted
      # xfce.xfce4-pulseaudio-plugin
      gnome.gnome-keyring
      # gthumb
      # networkmanagerapplet
      # xfce.catfish
      # xfce.orage
      # xfce.gigolo
      # xfce.xfce4-appfinder
      # xfce.xfce4-panel
      # xfce.xfce4-session
      # xfce.xfce4-settings
      # xfce.xfce4-power-manager
      # xfce.xfce4-terminal
      # xfce.xfce4-screensaver
      # xfce.xfce4-pulseaudio-plugin
      # xfce.xfce4-systemload-plugin
      # xfce.xfce4-weather-plugin
      # xfce.xfce4-whiskermenu-plugin
      # xfce.xfce4-xkb-plugin
      # xsel
      zuki-themes
    ];
    sessionVariables = { GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules"; };
  };
  # services = {
  # blueman-applet.enable = true;
  # };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Qogir-manjaro-dark";
      package = pkgs.qogir-icon-theme;
    };
    theme = {
      name = "zukitre-dark";
      package = pkgs.zuki-themes;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  ### Xfconf not working
  xfconf.settings = {
    xfce4-session = { }; # xfce4-session
    xfwm4 = {
      "general/workspace_count" = 4;
      "general/workspace_names" = [ "1" "2" "3" "4" ];
      "general/borderless_maximize" = true;
      "general/click_to_focus" = false;
      "general/cycle_apps_only" = false;
      "general/cycle_draw_frame" = true;
      "general/cycle_hidden" = true;
      "general/cycle_minimized" = false;
      "general/cycle_minimum" = true;
      "general/cycle_preview" = true;
      "general/cycle_raise" = false;
      "general/cycle_tabwin_mode" = 0;
      "general/cycle_workspaces" = false;
      "general/double_click_action" = "maximize"; # Window Manager -> Advanced -> Double click action
      "general/double_click_distance" = 5;
      "general/double_click_time" = 250;
      "general/easy_click" = "Alt";
      "general/focus_delay" = 141;
      "general/focus_hint" = true;
      "general/focus_new" = true;
      "general/prevent_focus_stealing" = false;
      "general/raise_delay" = 250;
      "general/raise_on_click" = true;
      "general/raise_on_focus" = false;
      "general/raise_with_any_button" = true;
      "general/scroll_workspaces" = false;
      "general/snap_resist" = false;
      "general/snap_to_border" = true;
      "general/snap_to_windows" = true;
      "general/snap_width" = 10;
      "general/theme" = "Qogir-Dark";
      "general/tile_on_move" = true;
      "general/title_alignment" = "center";
      "general/title_font" = 9;
      "general/title_horizontal_offset" = 0;
      "general/title_shadow_active" = false;
      "general/title_shadow_inactive" = false;
      "general/toggle_workspaces" = false;
      "general/wrap_cycle" = false;
      "general/wrap_layout" = false;
      "general/wrap_resistance" = 10;
      "general/wrap_windows" = false;
      "general/wrap_workspaces" = false;
      "general/zoom_desktop" = true;
      "general/zoom_pointer" = true;
    };

    xfce4-screensaver = {
      # 2023-07-29: MUST have leading slashes
      # FIXXME: this section is untested
      "/lock/saver-activation/delay" = 2;
      "/lock/saver-activation/enabled" = false;
      "/lock/user-switching/enabled" = false;
      #"/lock/enabled" = true; # Enable Lock Screen
      # FIXXME: trying to find the correct syntax for setting the lock screen boolean according to "my.isvm":
      #"/lock/enabled" =  "${nixos.config.networking.hostName}" == "nixosvms"; # error: undefined variable 'nixos'
      #"/lock/enabled" =  "${config.networking.hostName}" == "nixosvms"; # error: attribute 'networking' missing

      #"/lock/enabled" =  ! config.options.my.isvm; # error: attribute 'options' missing
      #"/lock/enabled" =  ! ${config.options.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
      #"/lock/enabled" =  ! ${nixos.config.options.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
      #"/lock/enabled" =  ! ${options.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
      #"/lock/enabled" =  ! "${options.my.isvm}"; # error: undefined variable 'options'
      #"/lock/enabled" =  ! options.my.isvm; # error: undefined variable 'options'

      #"/lock/enabled" =  ! config.my.isvm; #attribute 'my' missing
      #"/lock/enabled" =  ! my.isvm; # error: undefined variable 'my'
      #"/lock/enabled" =  ! ${config.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
      #"/lock/enabled" =  ! ${nixos.config.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
      #"/lock/enabled" =  ! ${my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
      #"/lock/enabled" =  ! "${my.isvm}"; # error: undefined variable 'my'

      #        "/lock/enabled" = enableSaver config.networking.hostName;

      "/saver/enabled" = true;
      "/saver/idle-activation/delay" = 9;
      "/saver/idle-activation/enabled" = true;
      "/saver/mode" = 0;
      "/screensavers/xfce-personal-slideshow/arguments" = "month";
      "/screensavers/xfce-personal-slideshow/location" = "month";
    }; # xfce4-screensaver

    xfce4-appfinder = { }; # xfce4-appfinder

    xsettings = {
      # "/Gdk/WindowScalingFactor" = 1;
      # "/Gtk/ButtonImages" = true;
      # "/Gtk/CanChangeAccels" = false;
      # "/Gtk/ColorPalette" = "green:gray10:gray30:gray75:gray90";
      # "/Gtk/CursorThemeName" = "default";
      # "/Gtk/CursorThemeSize" = 16;
      # "/Gtk/DecorationLayout" = "menu:minimize,maximize,close";
      # "/Gtk/DialogsUseHeader" = false;
      # "/Gtk/FontName" = 10;
      # "/Gtk/IconSizes" = ;
      # "/Gtk/KeyThemeName" = ;
      # "/Gtk/MenuBarAccel" = F10;
      # "/Gtk/MenuImages" = true;
      # "/Gtk/MonospaceFontName" = 10;
      # "/Gtk/TitlebarMiddleClick" = lower;
      # "/Gtk/ToolbarIconSize" = 3;
      # "/Gtk/ToolbarStyle" = icons;
      # "/Net/CursorBlink" = true;
      # "/Net/CursorBlinkTime" = 1200;
      # "/Net/DndDragThreshold" = 8;
      # "/Net/DoubleClickDistance" = 5;
      # "/Net/DoubleClickTime" = 400;
      # "/Net/EnableEventSounds" = false;
      # "/Net/EnableInputFeedbackSounds" = false;
      # "/Net/IconThemeName" = Moka;
      # "/Net/SoundThemeName" = default;
      # "/Net/ThemeName" = "Adwaita-dark-Xfce";
      # "/Xft/Antialias" = -1;
      # "/Xft/Hinting" = -1;
      # "/Xft/HintStyle" = hintnone;
      # "/Xft/RGBA" = none;
    }; # xsettings
    thunar = {
      # "last-view" = { };
    };
    keyboard-layout = {
      # 2023-07-29: MUST have leading slashes
      "/Default/XkbDisable" = false;
      "/Default/XkbLayout" = "br";
      "/Default/XkbModel" = "pc105";
      # "/Default/XkbOptions/Compose" = "compose:rctrl";
      # "/Default/XkbVariant" = "intl";
    }; # keyboard-layout
    # xfce4-panel = {
    #   # 2023-07-29: MUST have leading slashes
    #   # FIXXME: this section is not working completely; in particular: "whiskermenu"; "cpugraph"; "netload"; "eyes";

    #   # example configurations:
    #   # https://github.com/vhminh/dotfiles/blob/7b7dd80408658f0d76f8d0b518a314f5952146ec/nix/modules/desktop.nix#L62
    #   # https://github.com/lobre/nix-home/blob/8117fbdb4bca887b875f622132b3b9e9c737a5bf/roles/hm/xfce/xfconf.nix#L144 -> leading slashes! :-O

    #   "panels" = [ 1 ];
    #   "panels/dark-mode" = true;
    #   "panels/panel-1/nrows" = 1; # number of rows
    #   "panels/panel-1/mode" = 0; # Horizontal
    #   "panels/panel-1/output-name" = "Automatic";
    #   "panels/panel-1/span-monitors" = false;
    #   "panels/panel-1/background-style" = 0; # None (use system style)
    #   "panels/panel-1/icon-size" = 0; # Adjust size automatically
    #   "panels/panel-1/size" = 24; # Row size (pixels)
    #   "panels/panel-1/length" = 100.0;
    #   "panels/panel-1/length-adjust" = true;
    #   "panels/panel-1/position" = "p=6;x=0;y=0";
    #   "panels/panel-1/enable-struts" = true;
    #   "panels/panel-1/position-locked" = true;
    #   "panels/panel-1/plugin-ids" = [ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ];
    #   # Application menu = whiskermenu
    #   "plugins/plugin-1" = "whiskermenu";
    #   # Tasklist
    #   "plugins/plugin-2" = "tasklist";
    #   "plugins/plugin-2/grouping" = false;
    #   "plugins/plugin-2/show-handle" = true;
    #   "plugins/plugin-2/show-labels" = true;
    #   "plugins/plugin-2/flat-buttons" = false;
    #   "plugins/plugin-2/include-all-monitors" = true;
    #   "plugins/plugin-2/window-scrolling" = false;
    #   "plugins/plugin-2/sort-order" = 1; # Group title and timestamp
    #   "plugins/plugin-2/middle-click" = 0; # Nothing
    #   "plugins/plugin-2/show-wireframes" = false;
    #   "plugins/plugin-2/include-all-workspaces" = false;
    #   # Separator
    #   "plugins/plugin-3" = "separator";
    #   "plugins/plugin-3/style" = 0; # transparent
    #   "plugins/plugin-3/expand" = true;
    #   # Workspaces
    #   "plugins/plugin-4" = "pager";
    #   "plugins/plugin-4/rows" = 1;
    #   "plugins/plugin-4/miniature-view" = false; # show name instead of preview
    #   "plugins/plugin-4/numbering" = false;
    #   "plugins/plugin-4/workspace-scrolling" = false;
    #   # screenshooter (if order of this item is changed → also change order of symlink below: "files in ~/.config/")
    #   "plugins/plugin-5" = "screenshooter";
    #   # Separator
    #   "plugins/plugin-6" = "separator";
    #   "plugins/plugin-6/style" = 0; # transparent
    #   # Sys tray
    #   "plugins/plugin-7" = "systray";
    #   # CPU graph (if order of this item is changed → also change order of symlink below: "files in ~/.config/")
    #   "plugins/plugin-8" = "cpugraph";
    #   # Pulse audio
    #   "plugins/plugin-9" = "pulseaudio";
    #   "plugins/plugin-9/enable-keyboard-shortcuts" = true;
    #   # Network monitor (if order of this item is changed → also change order of symlink below: "files in ~/.config/")
    #   "plugins/plugin-10" = "netload";
    #   # clipboard
    #   "plugins/plugin-11" = "xfce4-clipman-plugin";
    #   "plugins/clipman/settings/save-on-quit" = true;
    #   "plugins/clipman/settings/max-texts-in-history" = 1000;
    #   "plugins/clipman/settings/add-primary-clipboard" = false;
    #   # Notification
    #   "plugins/plugin-12" = "notification-plugin";
    #   # Separator
    #   "plugins/plugin-13" = "separator";
    #   "plugins/plugin-13/style" = 0; # transparent
    #   # Power manager
    #   "plugins/plugin-14" = "power-manager-plugin";
    #   # Clock
    #   "plugins/plugin-15" = "clock";
    #   "plugins/plugin-15/digital-layout" = 3; # Time Only
    #   "plugins/plugin-15/digital-time-font" = "Sans 11";
    #   "plugins/plugin-15/digital-time-format" = "%a %d %R";
    #   "plugins/plugin-15/tooltip-format" = "%A %d %B %Y"; # Saturday 29 July 2023
    #   "plugins/plugin-15/mode" = 2; # digital
    #   "plugins/plugin-15/show-frame" = false;
    #   # Eyes: where's my mouse cursor?
    #   "plugins/plugin-16" = "eyes";
    # }; # xfce4-panel

    xfce4-panel = {
      "/configver" = 2;
      "/panels" = "[<1>, <2>, <3>]";
      "/panels/panel-1/autohide-behavior" = "uint32 0";
      "/panels/panel-1/background-alpha" = "uint32 100";
      "/panels/panel-1/background-style" = "uint32 0";
      "/panels/panel-1/disable-struts" = false;
      "/panels/panel-1/enter-opacity" = "uint32 100";
      "/panels/panel-1/leave-opacity" = "uint32 100";
      "/panels/panel-1/length" = "uint32 42";
      "/panels/panel-1/mode" = "uint32 0";
      "/panels/panel-1/nrows" = "uint32 1";
      "/panels/panel-1/plugin-ids" = "[<4>, <13>, <8>, <16>, <9>, <17>]";
      "/panels/panel-1/position" = "'p = 2;x = 1526;y = 15'";
      "/panels/panel-1/position-locked" = true;
      "/panels/panel-1/size" = "uint32 28";
      "/panels/panel-2/background-rgba" = "[ <1.0>, <1.0>, <1.0>, <0.0> ]";
      "/panels/panel-2/background-style" = "uint32 0";
      "/panels/panel-2/enter-opacity" = "uint32 100";
      "/panels/panel-2/leave-opacity" = "uint32 100";
      "/panels/panel-2/length" = "uint32 18";
      "/panels/panel-2/length-adjust" = true;
      "/panels/panel-2/plugin-ids" = "[ <1>, <3>, <5>, <6>, <2> ]";
      "/panels/panel-2/position" = "'p=9;x = 955;y = 21'";
      "/panels/panel-2/position-locked" = true;
      "/panels/panel-2/size" = "uint32 28";
      "/panels/panel-3/length" = "uint32 41";
      "/panels/panel-3/length-adjust" = false;
      "/panels/panel-3/plugin-ids" = "[ <10>, <11> ]";
      "/panels/panel-3/position" = "'p=6;x = 96;y = 25'";
      "/panels/panel-3/position-locked" = true;
      "/panels/panel-3/size" = "uint32 28";
      "/plugins/plugin-1" = "'separator'";
      "/plugins/plugin-1/expand" = true;
      "/plugins/plugin-1/style" = "uint32 0";
      "/plugins/plugin-10" = "'launcher'";
      "/plugins/plugin-10/disable-tooltips" = true;
      "/plugins/plugin-10/items" = "[ <'16184796581.desktop'> ]";
      "/plugins/plugin-10/move-first" = false;
      "/plugins/plugin-10/show-label" = false;
      "/plugins/plugin-11" = "'launcher'";
      "/plugins/plugin-11/cache-max-age" = 172800;
      "/plugins/plugin-11/disable-tooltips" = true;
      "/plugins/plugin-11/forecast/days" = 5;
      "/plugins/plugin-11/forecast/layout" = 1;
      "/plugins/plugin-11/items" = "[ <'16184798803.desktop'> ]";
      "/plugins/plugin-11/labels/label0" = 3;
      "/plugins/plugin-11/location/latitude" = "'36.538778'";
      "/plugins/plugin-11/location/longitude" = "' - 4.623335'";
      "/plugins/plugin-11/location/name" = "'Fuengirola, Costa del Sol Occidental'";
      "/plugins/plugin-11/msl" = 8;
      "/plugins/plugin-11/offset" = "'+02:00'";
      "/plugins/plugin-11/power-saving" = true;
      "/plugins/plugin-11/round" = true;
      "/plugins/plugin-11/scrollbox/animate" = true;
      "/plugins/plugin-11/scrollbox/color" = "'rgba(0,0,0,0)'";
      "/plugins/plugin-11/scrollbox/lines" = 1;
      "/plugins/plugin-11/scrollbox/show" = true;
      "/plugins/plugin-11/scrollbox/use-color" = false;
      "/plugins/plugin-11/show-label" = true;
      "/plugins/plugin-11/single-row" = true;
      "/plugins/plugin-11/theme-dir" = "'/usr/share/xfce4/weather/icons/simplistic'";
      "/plugins/plugin-11/timezone" = "'Europe/Madrid'";
      "/plugins/plugin-11/tooltip-style" = 1;
      "/plugins/plugin-11/units/altitude" = 0;
      "/plugins/plugin-11/units/apparent-temperature" = 0;
      "/plugins/plugin-11/units/precipitation" = 0;
      "/plugins/plugin-11/units/pressure" = 0;
      "/plugins/plugin-11/units/temperature" = 0;
      "/plugins/plugin-11/units/windspeed" = 0;
      "/plugins/plugin-13" = "'pulseaudio'";
      "/plugins/plugin-13/enable-keyboard-shortcuts" = true;
      "/plugins/plugin-13/mpris-players" = "'chromium.instance2513;firefox.instance1730'";
      "/plugins/plugin-16" = "'separator'";
      "/plugins/plugin-16/style" = "uint32 0";
      "/plugins/plugin-17" = "'separator'";
      "/plugins/plugin-17/style" = "uint32 0";
      "/plugins/plugin-2" = "'separator'";
      "/plugins/plugin-2/expand" = true;
      "/plugins/plugin-2/style" = "uint32 0";
      "/plugins/plugin-3" = "'clock'";
      "/plugins/plugin-3/digital-format" = "'%A %d %B, %R:%S'";
      "/plugins/plugin-4" = "'separator'";
      "/plugins/plugin-4/expand" = true;
      "/plugins/plugin-4/style" = "uint32 0";
      "/plugins/plugin-5" = "'weather'";
      "/plugins/plugin-5/cache-max-age" = 172800;
      "/plugins/plugin-5/forecast/days" = 5;
      "/plugins/plugin-5/forecast/layout" = 1;
      "/plugins/plugin-5/location/latitude" = "'36.595798'";
      "/plugins/plugin-5/location/longitude" = "'-4.637300'";
      "/plugins/plugin-5/location/name" = "'Mijas, Spain'";
      "/plugins/plugin-5/msl" = 418;
      "/plugins/plugin-5/offset" = "'+02:00'";
      "/plugins/plugin-5/power-saving" = true;
      "/plugins/plugin-5/round" = true;
      "/plugins/plugin-5/scrollbox/animate" = true;
      "/plugins/plugin-5/scrollbox/color" = "'rgba(0,0,0,0)'";
      "/plugins/plugin-5/scrollbox/lines" = 1;
      "/plugins/plugin-5/scrollbox/show" = true;
      "/plugins/plugin-5/scrollbox/use-color" = false;
      "/plugins/plugin-5/single-row" = true;
      "/plugins/plugin-5/theme-dir" = "'/usr/share/xfce4/weather/icons/simplistic'";
      "/plugins/plugin-5/tooltip-style" = 1;
      "/plugins/plugin-5/units/altitude" = 0;
      "/plugins/plugin-5/units/apparent-temperature" = 0;
      "/plugins/plugin-5/units/precipitation" = 0;
      "/plugins/plugin-5/units/pressure" = 0;
      "/plugins/plugin-5/units/temperature" = 0;
      "/plugins/plugin-5/units/windspeed" = 0;
      "/plugins/plugin-6" = "'notification-plugin'";
      "/plugins/plugin-8" = "'systray'";
      "/plugins/plugin-8/known-items" = "[<'steam'>, <'redshift'>, <'blueman'>, <'com.leinardi.gwe'>, <'discord1'>]";
      "/plugins/plugin-8/known-legacy-items" = "[<'steam'>, <'xfce4-power-manager'>, <'notas'>, <'redshift-gtk'>, <'bluetooth activado'>, <'discord'>, <'pamac-tray'>, <'syncthing'>, <'portapapeles'>, <'miniaplicación gestor de la red'>]";
      "/plugins/plugin-8/names-ordered" = "[<'miniaplicación gestor de la red'>, <'syncthing'>, <'notas'>, <'portapapeles'>, <'pamac-tray'>, <'discord'>, <'redshift-gtk'>, <'gwe'>, <'bluetooth activado'>]";
      "/plugins/plugin-8/square-icons" = true;
      "/plugins/plugin-9" = "'actions'";
    };

    xfce4-desktop = {
      # 2023-07-29: MUST NOT have leading slashes
      # FIXXME: this section is untested
      "desktop-icons/file-icons/show-filesystem" = false;
      "desktop-icons/file-icons/show-home" = false;
      "desktop-icons/file-icons/show-removable" = false;
      "desktop-icons/file-icons/show-trash" = true;
      "desktop-icons/icon-size" = 24;
      "desktop-menu/show" = false;
      "backdrop/single-workspace-mode" = true;
      "backdrop/single-workspace-number" = 3;
    }; # xfce4-desktop

    xsettings = {
      # "/Gdk/WindowScalingFactor" = 1;
      # "/Gtk/ButtonImages" = true;
      # "/Gtk/CanChangeAccels" = false;
      # "/Gtk/ColorPalette" = "green:gray10:gray30:gray75:gray90";
      # "/Gtk/CursorThemeName" = "default";
      # "/Gtk/CursorThemeSize" = 16;
      # "/Gtk/DecorationLayout" = "menu:minimize,maximize,close";
      # "/Gtk/DialogsUseHeader" = false;
      # "/Gtk/FontName" = 10;
      # "/Gtk/IconSizes" = ;
      # "/Gtk/KeyThemeName" = ;
      # "/Gtk/MenuBarAccel" = F10;
      # "/Gtk/MenuImages" = true;
      # "/Gtk/MonospaceFontName" = 10;
      # "/Gtk/TitlebarMiddleClick" = lower;
      # "/Gtk/ToolbarIconSize" = 3;
      # "/Gtk/ToolbarStyle" = icons;
      # "/Net/CursorBlink" = true;
      # "/Net/CursorBlinkTime" = 1200;
      # "/Net/DndDragThreshold" = 8;
      # "/Net/DoubleClickDistance" = 5;
      # "/Net/DoubleClickTime" = 400;
      # "/Net/EnableEventSounds" = false;
      # "/Net/EnableInputFeedbackSounds" = false;
      # "/Net/IconThemeName" = Moka;
      # "/Net/SoundThemeName" = default;
      # "/Net/ThemeName" = "Adwaita-dark-Xfce";
      # "/Xft/Antialias" = -1;
      # "/Xft/Hinting" = -1;
      # "/Xft/HintStyle" = hintnone;
      # "/Xft/RGBA" = none;
    }; # xsettings

    xfce4-power-manager = {
      # 2023-07-29: MUST have leading slashes
      # FIXXME: this section is untested
      "/xfce4-power-manager/blank-on-ac" = 0;
      "/xfce4-power-manager/brightness-switch" = 1;
      "/xfce4-power-manager/brightness-switch-restore-on-exit" = -1;
      "/xfce4-power-manager/dpms-enabled" = true;
      "/xfce4-power-manager/dpms-on-ac-off" = 0;
      "/xfce4-power-manager/dpms-on-ac-sleep" = 0;
      "/xfce4-power-manager/lock-screen-suspend-hibernate" = true;
      "/xfce4-power-manager/show-tray-icon" = 1;

      "/xfce4-power-manager/handle-brightness-keys" =
        true; # FIXXME: doesn't work on floyd yet
      "/xfce4-power-manager/power-button-action" = 3; # Ask
      "/xfce4-power-manager/lid-action-on-battery" = 0; # just blank screen
      "/xfce4-power-manager/lid-action-on-ac" = 0; # just blank screen
      "/xfce4-power-manager/logind-handle-lid-switch" = false;
      "/xfce4-power-manager/critical-power-action" = 3; # Ask
    }; # xfce4-power-manager

    xfce4-mime-settings = { }; # xfce4-mime-settings

    xfce4-mixer = {
      # 2023-07-29: MUST have leading slashes
      # FIXXME: this section is untested
      # "/sound-card" = "HDAIntelHDMIAlsamixer";
      #"/volume-step-size" = 5;
    }; # xfce4-mixer

    xfce4-notifyd = {
      # "/applications/known_applications" = <<UNSUPPORTED>>;
      # "/log-level" = 0;
      # "/log-level-apps" = 0;
      # "/notify-location" = 2;
      # "/primary-monitor" = 0;
    }; # xfce4-notifyd

    ristretto = {
      # "window/navigationbar/position" = left;
    }; # ristretto

    thunar-volman = {
      # 2023-07-29: MUST have leading slashes
      # FIXXME: this section is untested
      "/autobrowse/enabled" = true;
      # "/autoburn/audio-cd-command" = -a;
      # "/autoburn/data-cd-command" = -d;
      # "/autoburn/enabled" = false;
      # "/autoipod/enabled" = false;
      # "/autokeyboard/enabled" = false;
      "/automount-drives/enabled" = true;
      "/automount-media/enabled" = true;
      "/automouse/enabled" = false;
      "/autoopen/enabled" = false;
      "/autophoto/enabled" = false;
      # "/autoplay-audio-cds/command" = --device=%d;
      # "/autoplay-audio-cds/enabled" = true;
      # "/autoplay-video-cds/command" = --device=%d;
      # "/autoplay-video-cds/enabled" = true;
      # "/autoprinter/enabled" = false;
      "/autorun/enabled" = false;
      # "/autotablet/enabled" = false;
    }; # thunar-volman

    thunar = {
      # 2023-07-29: MUST have leading slashes
      # FIXXME: this section is untested
      # "/hidden-bookmarks" = <<UNSUPPORTED>>;
      # "/hidden-devices" = <<UNSUPPORTED>>;
      # "/last-details-view-column-order" = "THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_DATE_MODIFIED,THUNAR_COLUMN_TYPE,THUNAR_COLUMN_DATE_ACCESSED,THUNAR_COLUMN_OWNER,THUNAR_COLUMN_PERMISSIONS,THUNAR_COLUMN_MIME_TYPE,THUNAR_COLUMN_GROUP";
      # "/last-details-view-column-widths" = "50,151,209,50,1083,50,50,81,1045,1074,50,50,50,1244";
      # "/last-details-view-fixed-columns" = true;
      # "/last-details-view-visible-columns" = "THUNAR_COLUMN_DATE_MODIFIED,THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_TYPE";
      # "/last-details-view-zoom-level" = "THUNAR_ZOOM_LEVEL_SMALLEST";
      # "/last-icon-view-zoom-level" = "THUNAR_ZOOM_LEVEL_NORMAL";
      # "/last-location-bar" = "ThunarLocationEntry";
      # "/last-separator-position" = 170;
      "/last-show-hidden" = true;
      # "/last-side-pane" = "ThunarShortcutsPane";
      # "/last-sort-column" = "THUNAR_COLUMN_DATE_MODIFIED";
      # "/last-sort-order" = "GTK_SORT_DESCENDING";
      # "/last-splitview-separator-position" = 1194;
      # "/last-view" = "ThunarDetailsView";
      # "/last-window-height" = 1384;
      # "/last-window-maximized" = true;
      # "/last-window-width" = 2560;
      "/misc-date-style" = "THUNAR_DATE_STYLE_ISO";
      "/misc-middle-click-in-tab" = false;
      "/misc-single-click" = false;
      "/misc-thumbnail-mode" = "THUNAR_THUMBNAIL_MODE_NEVER";
      "/misc-volume-management" = false;
    }; # thunar

    xfce4-settings-manager = {
      #"/last/window-height" = 1029;
      #"/last/window-width" = 734;
    }; # xfce4-settings-manager
  };
}
