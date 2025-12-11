{ lib, config, pkgs, desktop, hostname, ... }:
let
  inherit (lib) mkIf mkDefault;
  graphics = config.hardware.graphics.cards;
  backend = config.desktop.backend;
in
{
  config = mkIf (backend == "x11") {
    services = {
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
        xkb =
          # mkIf (hostname == "nitro" || hostname == "scrubber") {
          #   layout = "br";
          #   variant = "abnt2";
          #   model = "pc105";
          # };
          if (hostname == "nitro") || (hostname == "virtual") then {
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
