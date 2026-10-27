{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption mkOptionDefault;
  backend = config.desktop.display-servers.backend;
in
{
  options.desktop.display-servers.x11 = {
    numlock = mkOption {
      type = lib.types.bool;
      default = false;
      description = "Ativar numlock na inicializacao da sessao X11 via numlockx.";
    };
  };

  config = mkIf (backend == "x11") {
    services = {
      xserver = {
        enable = mkOptionDefault true;
        displayManager = {
          sessionCommands = ''
            # GTK2_RC_FILES must be available to the display manager.
            export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
            ${lib.optionalString config.desktop.display-servers.x11.numlock ''
              ${pkgs.numlockx}/bin/numlockx on
            ''}
          '';
        };
        xkb = {
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
