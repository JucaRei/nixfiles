{ lib, config, pkgs, desktop, hostname, ... }:
let
  inherit (lib) mkIf mkOptionDefault optional;
  graphics = config.hardware.graphics.cards;
  backend = config.desktop.display-servers.backend;
in
{
  config = mkIf (backend == "x11") {
    environment = {
      systemPackages = mkIf (desktop == "bspwm") (with pkgs; [
        wmctrl
        notify-desktop
        xdotool
        ydotool
      ]);

      # Fix issue with java applications and tiling window managers.
      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = (mkIf (desktop == "bspwm")) "1";
        LIBVA_DRIVER_NAME = mkIf (graphics.gpu == "nvidia" || graphics.gpu == "hybrid-nvidia") "nvidia";
        VDPAU_DRIVER = mkIf (graphics.gpu == "nvidia" || graphics.gpu == "hybrid-nvidia") "nvidia";
      };
    };

    services = {
      gnome.gnome-keyring = (mkIf (desktop != "kde" || desktop != "pantheon")) {
        enable = true;
      };
      xserver = {
        enable = mkOptionDefault true;
        displayManager = {
          sessionCommands =
            if hostname != "nitro" then
              ''
                # GTK2_RC_FILES must be available to the display manager.
                export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
              ''
            else
              ''
                # GTK2_RC_FILES must be available to the display manager.
                export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
                ${pkgs.numlockx}/bin/numlockx on
              '';
        };
        xkb =
          # mkIf (hostname == "nitro" || hostname == "scrubber") {
          #   layout = "br";
          #   variant = "abnt2";
          #   model = "pc105";
          # };
          if (hostname == "nitro") || (hostname == "scrubber") then {
            layout = "us,br";
            variant = "alt-intl,abnt2";
            options = "lv3:ralt_switch,grp_led:scroll";
            model = "pc105";
          }
          else {
            layout = "us";
            variant = "mac,";
            model = "pc104";
          };
      };
    };
  };
}
