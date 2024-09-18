{ config, lib, namespace, pkgs, ... }:
let
  inherit (lib) mkIf mkForce;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.programs.terminal.emulators.alacritty;
in
{
  options.${namespace}.programs.terminal.emulators.alacritty = {
    enable = mkBoolOpt false "enable alacritty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      # catppuccin.enable = true;

      settings = {
        shell = {
          program = "fish";
        };

        window = {
          padding = {
            x = 8;
            y = 6;
          };
          dimensions = {
            columns = 140;
            lines = 50;
          };
          decorations = "none";
        };

        selection = {
          # When set to `true`, selected text will be copied to the primary clipboard.
          save_to_clipboard = true;
          semantic_escape_chars = ",│`|:\"' ()[]{}<>";

        };

        mouse = {
          bindings = [
            {
              mouse = "Right";
              action = "PasteSelection";
            }
          ];
        };

        env = {
          TERM = "xterm-256color";
          WINIT_X11_SCALE_FACTOR = "1.0";
        };

        ## SCROLLING ------------------------------------------------------
        scrolling = {
          # Maximum number of lines in the scrollback buffer.
          # Specifying '0' will disable scrolling.
          history = 10000;

          # Number of lines the viewport will move for every line scrolled when
          # scrollback is enabled (history > 0).
          multiplier = 3;
        };

        bell = {
          animation = "EaseOutExpo"; # "Linear";
          duration = 0; # 20;
          color = "0xffffff";
          command = {
            program = "paplay";
            args = [ "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/dialog-error.oga" ];
          };
        };

        # If `true`, bold text is drawn using the bright color variants.
        # draw_bold_text_with_bright_colors = true; #deprecated
        live_config_reload = true;
        ipc_socket = true;

        font = {
          offset.y = -1;
          size = mkForce 13.5;
          bold = {
            family = config.stylix.fonts.monospace.name;
            style = "Regular";
          };
        };
      };
    };
  };
}
