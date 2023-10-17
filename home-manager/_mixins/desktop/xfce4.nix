{ config, pkgs, lib, ...}: {
  services = {
    blueman-applet.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "elementary-Xfce-dark";
      package = pkgs.elementary-xfce-icon-theme;
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

  # xfce4-session = { };

  xfwm4 = {
    "general/workspace_count" = 4;
    "general/workspace_names" = [ "1" "2" "3" "4" ];
    "general/borderless_maximize" = true;
    "general/click_to_focus" = false;
    "general/cycle_apps_only" = false;
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
    "general/theme" = "Adwaita-dark-Xfce";
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
  }; # xfwm4

  #xfce4-desktop = {
  # 2023-07-29: MUST NOT have leading slashes
  # FIXXME: this section is untested
  #  "desktop-icons/file-icons/show-filesystem" = false;
  #  "desktop-icons/file-icons/show-home" = false;
  #  "desktop-icons/file-icons/show-removable" = false;
  #  "desktop-icons/file-icons/show-trash" = true;
  #  "desktop-icons/icon-size" = 32;
  #  "desktop-menu/show" = false;
  #  "backdrop/single-workspace-mode" = true;
  #  "backdrop/single-workspace-number" = 3;
  #}; # xfce4-desktop

  # xfce4-panel = {
  #   # FIXXME: this section is not working completely; in particular: "whiskermenu"; "cpugraph"; "netload"; "eyes";

  #   # example configurations:
  #   # https://github.com/vhminh/dotfiles/blob/7b7dd80408658f0d76f8d0b518a314f5952146ec/nix/modules/desktop.nix#L62
  #   # https://github.com/lobre/nix-home/blob/8117fbdb4bca887b875f622132b3b9e9c737a5bf/roles/hm/xfce/xfconf.nix#L144 -> leading slashes! :-O

  #   #  "panels" = [ 1 ];
  #   #  "panels/dark-mode" = true;
  #   #  "panels/panel-1/nrows" = 1; # number of rows
  #   #  "panels/panel-1/mode" = 0; # Horizontal
  #   #  "panels/panel-1/output-name" = "Automatic";
  #   #  "panels/panel-1/span-monitors" = false;
  #   #  "panels/panel-1/background-style" = 0; # None (use system style)
  #   #  "panels/panel-1/icon-size" = 0; # Adjust size automatically
  #   #  "panels/panel-1/size" = 24; # Row size (pixels)
  #   #  "panels/panel-1/length" = 100.0;
  #   #  "panels/panel-1/length-adjust" = true;
  #   #  "panels/panel-1/position" = "p=6;x=0;y=0";
  #   #  "panels/panel-1/enable-struts" = true;
  #   ##  "panels/panel-1/position-locked" = true;
  #   #  "panels/panel-1/plugin-ids" = [ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ];
  #   # Application menu = whiskermenu
  #   #  "plugins/plugin-1" = "whiskermenu";
  #   # Tasklist
  #   #  "plugins/plugin-2" = "tasklist";
  #   #  "plugins/plugin-2/grouping" = false;
  #   #  "plugins/plugin-2/show-handle" = true;
  #   #  "plugins/plugin-2/show-labels" = true;
  #   #  "plugins/plugin-2/flat-buttons" = false;
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

  # xfce4-screensaver = {
  #   # 2023-07-29: MUST have leading slashes
  #   # FIXXME: this section is untested
  #   "/lock/saver-activation/delay" = 2;
  #   "/lock/saver-activation/enabled" = false;
  #   "/lock/user-switching/enabled" = false;
  #   #"/lock/enabled" = true; # Enable Lock Screen
  #   # FIXXME: trying to find the correct syntax for setting the lock screen boolean according to "my.isvm":
  #   #"/lock/enabled" =  "${nixos.config.networking.hostName}" == "nixosvms"; # error: undefined variable 'nixos'
  #   #"/lock/enabled" =  "${config.networking.hostName}" == "nixosvms"; # error: attribute 'networking' missing

  #   #"/lock/enabled" =  ! config.options.my.isvm; # error: attribute 'options' missing
  #   #"/lock/enabled" =  ! ${config.options.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
  #   #"/lock/enabled" =  ! ${nixos.config.options.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
  #   #"/lock/enabled" =  ! ${options.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
  #   #"/lock/enabled" =  ! "${options.my.isvm}"; # error: undefined variable 'options'
  #   #"/lock/enabled" =  ! options.my.isvm; # error: undefined variable 'options'

  #   #"/lock/enabled" =  ! config.my.isvm; #attribute 'my' missing
  #   #"/lock/enabled" =  ! my.isvm; # error: undefined variable 'my'
  #   #"/lock/enabled" =  ! ${config.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
  #   #"/lock/enabled" =  ! ${nixos.config.my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
  #   #"/lock/enabled" =  ! ${my.isvm}; # error: syntax error, unexpected DOLLAR_CURLY
  #   #"/lock/enabled" =  ! "${my.isvm}"; # error: undefined variable 'my'

  #   #        "/lock/enabled" = enableSaver config.networking.hostName;

  #   "/saver/enabled" = true;
  #   "/saver/idle-activation/delay" = 9;
  #   "/saver/idle-activation/enabled" = true;
  #   "/saver/mode" = 0;
  #   "/screensavers/xfce-personal-slideshow/arguments" = "month";
  #   "/screensavers/xfce-personal-slideshow/location" = "month";
  # }; # xfce4-screensaver

  #xfce4-appfinder = { }; # xfce4-appfinder

  # keyboard-layout = {
  # 2023-07-29: MUST have leading slashes
  #   "/Default/XkbDisable" = false;
  #   "/Default/XkbLayout" = "br";
  #   "/Default/XkbModel" = "pc105";
  # "/Default/XkbOptions/Compose" = "compose:rctrl";
  # "/Default/XkbVariant" = "intl";
  # }; # keyboard-layout

  #thunar-volman = {
  # 2023-07-29: MUST have leading slashes
  # FIXXME: this section is untested
  #  "/autobrowse/enabled" = true;
  # "/autoburn/audio-cd-command" = -a;
  # "/autoburn/data-cd-command" = -d;
  # "/autoburn/enabled" = false;
  # "/autoipod/enabled" = false;
  # "/autokeyboard/enabled" = false;
  #  "/automount-drives/enabled" = true;
  #  "/automount-media/enabled" = true;
  #  "/automouse/enabled" = false;
  #  "/autoopen/enabled" = false;
  #  "/autophoto/enabled" = false;
  # "/autoplay-audio-cds/command" = --device=%d;
  # "/autoplay-audio-cds/enabled" = true;
  # "/autoplay-video-cds/command" = --device=%d;
  # "/autoplay-video-cds/enabled" = true;
  # "/autoprinter/enabled" = false;
  #  "/autorun/enabled" = false;
  # "/autotablet/enabled" = false;
  # }; # thunar-volman

  #thunar = {
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
  #"/last-show-hidden" = true;
  # "/last-side-pane" = "ThunarShortcutsPane";
  # "/last-sort-column" = "THUNAR_COLUMN_DATE_MODIFIED";
  # "/last-sort-order" = "GTK_SORT_DESCENDING";
  # "/last-splitview-separator-position" = 1194;
  # "/last-view" = "ThunarDetailsView";
  # "/last-window-height" = 1384;
  # "/last-window-maximized" = true;
  # "/last-window-width" = 2560;
  #"/misc-date-style" = "THUNAR_DATE_STYLE_ISO";
  #"/misc-middle-click-in-tab" = false;
  #"/misc-single-click" = false;
  #"/misc-thumbnail-mode" = "THUNAR_THUMBNAIL_MODE_NEVER";
  #"/misc-volume-management" = false;
  # }; # thunar
}
