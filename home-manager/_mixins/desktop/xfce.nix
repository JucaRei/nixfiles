{ config, pkgs, lib, ... }:
with lib.hm.gvariant;
{
  services = {
    blueman-applet.enable = true;
  };

  dconf.settings = {
    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };
    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Breeze-Hacked";
      gtk-theme = "Orchis-Red-Dark-Compact";
      icon-theme = "ePapirus-Dark";
      locate-pointer = true;
      show-battery-percentage = true;
    };
    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 159;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 407 91 ];
      window-size = mkTuple [ 1102 826 ];
    };
  };

  xfconf.settings = {
    xsettings = { };
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
    thunar = {
      # "last-view" = { };
    };
    xfce4-panel = { };
    xfce4-desktop = { };
  };


  home = {
    packages = with pkgs; [
      ulauncher
      tokyo-night-gtk
      orchis-theme
      papirus-icon-theme
      qogir-theme
      qogir-icon-theme
    ];
  };
}
