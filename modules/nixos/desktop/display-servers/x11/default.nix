{
  lib,
  config,
  pkgs,
  hostname,
  ...
}:
let
  inherit (lib) mkIf mkOptionDefault;
  backend = config.desktop.display-servers.backend;
in
{
  config = mkIf (backend == "x11") {
    services = {
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
          if (hostname == "nitro") || (hostname == "virtual") then
            {
              layout = lib.mkDefault "us,br";
              variant = lib.mkDefault "alt-intl,abnt2";
              options = lib.mkDefault "lv3:ralt_switch,grp_led:scroll";
              model = lib.mkDefault "pc105";
            }
          else
            {
              layout = lib.mkDefault "us";
              variant = lib.mkDefault "mac,";
              model = lib.mkDefault "pc104";
            };
      };

      # Configuração global do Touchpad (Natural Scrolling, Tapping, Clickfinger)
      libinput = {
        enable = mkOptionDefault true;
        touchpad = {
          naturalScrolling = true;
          tapping = true;
          clickMethod = "clickfinger";
          scrollMethod = "twofinger";
          disableWhileTyping = true;
        };
      };
    };
  };
}
