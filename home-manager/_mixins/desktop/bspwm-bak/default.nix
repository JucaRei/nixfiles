{ config, lib, pkgs, username, hostname, ... }:
with lib.hm.gvariant; {
  imports = [
    ### Import selected theme
    # ./themes/default
    ./themes/everforest
    ./xsession.nix
  ];

  config = {
    modules.bspwm-xs.enable = true;
    home = {
      packages = with pkgs; [
        # Default packages for ALL
        pamixer # Pulseaudio command line mixer
        gnome.gvfs # Virtual Filesystem support library
        cifs-utils # Tools for managing Linux CIFS client filesystems
        lm_sensors # Tools for reading hardware sensors
        lxappearance-gtk2 # Lightweight program for configuring the theme and fonts of gtk applications
        imagemagick
        xclip
        lsof
        xdo
        wmctrl
        mate.mate-polkit
        brillo
        kbdlight
        acpi
      ];

      sessionVariables = {
        GLFW_IM_MODULE = "ibus";
        LIBPROC_HIDE_KERNEL = "true"; # prevent display kernel threads in top
        QT_QPA_PLATFORMTHEME = "gtk3";
        "TERM" = "xterm";
        GIO_EXTRA_MODULES = "${pkgs.gnome.gvfs}/lib/gio/modules";
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
      };
      sessionPath = [ "$HOME/.local/bin" ];
    };
  };
}
