{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  home = {
    packages = with pkgs; [
      gnomeExtensions.logo-menu
      # gnomeExtensions.aylurs-widgets
      gnomeExtensions.rounded-window-corners
      gnomeExtensions.vitals
      gnomeExtensions.pop-shell
      gnomeExtensions.space-bar
      gnomeExtensions.top-bar-organizer
      # gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      # gnomeExtensions.clipboard-indicator
      # gnomeExtensions.user-themes
      # gnomeExtensions.hide-activities-button
      gnomeExtensions.caffeine
      gnome.mutter
      gnomeExtensions.bluetooth-quick-connect
      gnome-extension-manager
      # gnome.libgnome-keyring
      # gnomeExtensions.forge
      # gnomeExtensions.gsconnect # kdeconnect enabled in default.nix
      gnomeExtensions.dash-to-dock
      # gnomeExtensions.arcmenu
      # gnomeExtensions.battery-indicator-upower
      gnomeExtensions.tray-icons-reloaded
      # gnomeExtensions.removable-drive-menu
      # gnomeExtensions.dash-to-panel
      # gnomeExtensions.battery-indicator-upower
      # gnomeExtensions.workspace-indicator-2
      # gnomeExtensions.pip-on-top
      # gnomeExtensions.fullscreen-avoider
      layan-gtk-theme
      catppuccin-gtk

      gnome3.gvfs
      gnome3.nautilus
    ];
    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features
    sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
    };
  };

  # GTK Configuration
  gtk = {
    enable = true;
    font = {
      package = pkgs.fira;
      name = "Fira 10";
    };
    theme = {
      # package = pkgs.whitesur-gtk-theme;
      # name = "WhiteSur-light-solid-pink";
      package = pkgs.layan-gtk-theme;
      name = "Layan-dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "EPapirus-dark";
    };
  };
  # dconf = {
  #   settings = {
  #     "ca/desrt/dconf-editor" = {
  #       show-warning = false;
  #     };
  #     "org/gnome/desktop/background" = {
  #       picture-uri = "file://${../config/wallpapers/nix-asci.png}";
  #     };
  #     "org/gnome/control-center" = {
  #       last-panel = "mouse";
  #       window-state = mkTuple [ 1904 1035 ];
  #     };
  #     "org/gnome/shell/extensions/vitals" = {
  #       show-storage = false;
  #       show-voltage = true;
  #       show-memory = true;
  #       show-fan = true;
  #       show-temperature = true;
  #       show-processor = true;
  #       show-network = true;
  #     };
  #     "org/gnome/desktop/wm/preferences" = {
  #       workspace-name = [ "Main" ];
  #       button-layout = "appmenu:minimize,maximize,close";
  #     };
  #     "org/gnome/desktop/interface" = {
  #       color-scheme = "prefer-dark";
  #       cursor-theme = "Breeze_Hacked";
  #       enable-animations = true;
  #       enable-hot-corners = false;
  #       font-antialiasing = "grayscale";
  #       font-hinting = "slight";
  #       gtk-theme = "Layan-dark";
  #       icon-theme = "EPapirus-dark";
  #       locale-pointer = true;
  #       clock-format = "24h";
  #       clock-show-weekday = true;
  #       clock-show-seconds = false;
  #       show-battery-percentage = true;
  #     };
  #     "org/gnome/desktop/peripherals/keyboard" = {
  #       numlock-state = true;
  #     };
  #     "org/gnome/desktop/peripherals/touchpad" = {
  #       two-finger-scrolling-enabled = true;
  #     };
  #     "org/gnome/desktop/sound" = {
  #       allow-volume-above-100-percent = true;
  #     };
  #     "org/gnome/file-roller/dialogs/extract" = {
  #       recreate-folders = true;
  #       skip-newer = false;
  #     };
  #     "org/gnome/file-roller/listing" = {
  #       list-mode = "as-folder";
  #       name-column-width = 250;
  #       show-path = false;
  #       sort-method = "name";
  #       sort-type = "ascending";
  #     };
  #     "org/gnome/nautilus/preferences" = {
  #       default-folder-viewer = "icon-view";
  #       migrated-gtk-settings = true;
  #       search-filter-time-type = "last_modified";
  #     };
  #     "org/gnome/gnome-session" = {
  #       auto-save-session = true;
  #     };
  #     "org/gnome/mutter" = {
  #       center-new-windows = true;
  #     };
  #     "org/gnome/shell" = {
  #       app-picker-layout = "[{'com.hunterwittenborn.Celeste.desktop': <{'position': <0>}>, 'org.gnome.Weather.desktop': <{'position': <1>}>, 'ca.desrt.dconf-editor.desktop': <{'position': <2>}>, 'org.gnome.clocks.desktop': <{'position': <3>}>, 'emacs.desktop': <{'position': <4>}>, 'emacsclient.desktop': <{'position': <5>}>, 'org.gnome.Extensions.desktop': <{'position': <6>}>, 'org.gnome.Calculator.desktop': <{'position': <7>}>, 'firefox.desktop': <{'position': <8>}>, 'simple-scan.desktop': <{'position': <9>}>, 'gparted.desktop': <{'position': <10>}>, 'org.gnome.Settings.desktop': <{'position': <11>}>, 'gsmartcontrol.desktop': <{'position': <12>}>, 'org.gnome.gThumb.desktop': <{'position': <13>}>, 'htop.desktop': <{'position': <14>}>, 'Utilities': <{'position': <15>}>, 'maestral.desktop': <{'position': <16>}>, 'micro.desktop': <{'position': <17>}>, 'pavucontrol.desktop': <{'position': <18>}>, 'org.gnome.Software.desktop': <{'position': <19>}>}]";
  #       disabled-extensions = [ "widgets@aylur" "window-list@gnome-shell-extensions.gcampax.github.com" "workspace-indicator@gnome-shell-extensions.gcampax.github.com" "appindicatorsupport@rgcjonas.gmail.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "battery-indicator@jgotti.org" "launch-new-instance@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" ];
  #       favorite-apps = [ "org.gnome.Calendar.desktop" "org.gnome.Photos.desktop" "org.gnome.Nautilus.desktop" "code.desktop" "firefox.desktop" "com.gexperts.Tilix.desktop" ];
  #       welcome-dialog-last-shown-version = "44.2";
  #       disable-user-extensions = false;
  #       disabled-user-extensions = [ ];
  #       disable-extension-version-validation = true;
  #       enabled-extensions = [
  #         "dash-to-dock@micxgx.gmail.com"
  #         "drive-menu@gnome-shell-extensions.gcampax.github.com"
  #         "Hide_Activities@shay.shayel.org"
  #         "caffeine@patapon.info"
  #         "blur-my-shell@aunetx"
  #         "user-theme@gnome-shell-extensions.gcampax.github.com"
  #       ];
  #     };
  #     "org/gnome/shell/extensions/aylurs-widgets" = {
  #       dash-links-names = [ "reddit" "youtube" "gmail" "twitter" "github" ];
  #       dash-links-urls = [ "https://www.reddit.com/" "https://www.youtube.com/" "https://www.gmail.com/" "https://twitter.com/" "https://www.github.com/" ];
  #     };
  #     "org/gnome/shell/extensions/bluetooth-quick-connect" = {
  #       bluetooth-auto-power-on = true;
  #       refresh-button-on = true;
  #       show-battery-value-on = true;
  #     };
  #     "org/gnome/shell/extensions/caffeine" = {
  #       indicator-position-max = 2;
  #     };
  #     "org/gnome/shell/extensions/dash-to-dock" = {
  #       # position
  #       dock-position = "BOTTOM";
  #       dock-fixed = false;
  #       extend-height = false;
  #       # icons
  #       dash-max-icon-size = 48;
  #       icon-size-fixed = true;
  #       show-apps-at-top = true;
  #       # clicking
  #       click-action = "previews";
  #       scroll-action = "cycle-windows";
  #       shift-click-action = "launch";
  #       middle-click-action = "minimise";
  #       shift-middle-click-action = "launch";
  #       running-indicator-dominant-color = true;
  #       running-indicator-style = "DASHES";
  #       # visibility
  #       intellihide = true;
  #       isolate-workspaces = true;
  #       autohide = true;
  #       autohide-in-full-screen = true;
  #       require-pressure-to-show = true;
  #       # transparency
  #       transparency-mode = "FIXED";
  #       background-opacity = 0.1;
  #     };
  #     "org/gnome/shell/extensions/blur-my-shell" = {
  #       blur-dash = false;
  #       blur-panel = false;
  #       brightness = 0.75;
  #       sigma = 25;
  #     };
  #     "org/gnome/shell/extensions/user-theme" = {
  #       name = "WhiteSur-light-solid-pink";
  #     };
  #   };
  # };
}
