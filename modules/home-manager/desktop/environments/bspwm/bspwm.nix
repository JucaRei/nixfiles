{ config, lib, pkgs, useNixGL ? false, osConfig ? null, ... }:
let
  inherit (lib) mkOption mkIf optionals;
  inherit (lib.types) bool listOf str;
  cfg = config.desktop.bspwm;

  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);

  isNixOS = osConfig != null;
in
{
  options.desktop.bspwm = {
    enable = mkOption {
      type = bool;
      default = true;
      description = "Enable bspwm window manager";
    };

    extraConfig = mkOption {
      type = str;
      default = "";
      description = "Additional bspwmrc configuration to append";
    };

    rules = mkOption {
      type = listOf str;
      default = [ ];
      description = "bspwm rules for specific applications";
    };
  };

  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      windowManager = {
        bspwm = {
          enable = true;
          package = nixGLWrapper pkgs.bspwm;
          monitors = {
            "*" = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" ];
          };
          settings = {
            split_ratio = 0.5;
            border_width = 2;
            window_gap = 8;
            top_padding = 32;
            bottom_padding = 8;
            left_padding = 8;
            right_padding = 8;
            normal_border_color = "#444444";
            active_border_color = "#5577aa";
            focused_border_color = "#88aacc";
            presel_feedback_color = "#ff6666";
          };
          extraConfig = ''
            # Remove all borders by default
            bspc config border_width 2

            # Mouse bindings for floating windows
            bspc config pointer_modifier mod4
            bspc config pointer_action1 move
            bspc config pointer_action2 resize_side
            bspc config pointer_action2 resize_corner
            bspc config pointer_action3 resize

            # Focus follows mouse
            bspc config focus_follows_pointer true

            # External rules
            ${lib.concatStringsSep "\n" cfg.rules}

            ${cfg.extraConfig}
          '';
        };
      };
    };

    home = {
      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        GLFW_IM_MODULE = "ibus";
        TERM = "xterm-256color";
        QT_STYLE_OVERRIDE = lib.mkDefault "";
        LOG_ICONS = "true";
      };

      shellAliases = {
        is_picom_on = "pgrep -x 'picom' > /dev/null && echo 'on' || echo 'off'";
      };
    };
  };
}
