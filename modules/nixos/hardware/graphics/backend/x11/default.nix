{ lib, config, pkgs, desktop, hostname, namespace, ... }:
let
  inherit (lib) mkIf mkDefault optional;
  graphics = config.${namespace}.hardware.graphics;
in
{
  config = mkIf (graphics.enable && graphics.backend == "x11") {
    environment = {
      systemPackages = with pkgs; [
        wmctrl
        notify-desktop
        xdotool
        ydotool
      ];

      # Fix issue with java applications and tiling window managers.
      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = (mkIf (desktop == "bspwm")) "1";
        LIBVA_DRIVER_NAME = mkIf (graphics.gpu == "nvidia" || graphics.gpu == "hybrid-nvidia") "nvidia";
        VDPAU_DRIVER = mkIf (graphics.gpu == "nvidia" || graphics.gpu == "hybrid-nvidia") "nvidia";
      };
    };
    services = {
      dbus.enable = true;

      usbmuxd.enable = true; # for IOS;

      gvfs = {
        enable = mkDefault true;
      };

      gnome.gnome-keyring = (mkIf (desktop != "kde" || desktop != "pantheon")) {
        enable = true;
      };

      xserver = {

        enable = mkDefault true;

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

        # xkb =
        #   if (hostname == "nitro") || (hostname == "scrubber") then {
        #     layout = "br";
        #     variant = "abnt2";
        #     model = "pc105";
        #   }
        #   else {
        #     layout = "us";
        #     variant = "mac";
        #     model = "pc104";
        #   };
      };
    };
  };
}
