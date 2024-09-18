{ config, lib, namespace, pkgs, ... }:
let
  inherit (lib) mkIf mkForce;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.programs.terminal.emulators.foot;
in
{
  options.${namespace}.programs.terminal.emulators.foot = {
    enable = mkBoolOpt false "enable foot terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;
      # catppuccin.enable = true;

      settings = {
        main = {
          app-id = "foot";
          title = "foot";
          locked-title = "no";
          notify = "notify-send -a \${app-id} -i \${app-id} \${title} \${body}";
          dpi-aware = "yes";
          bold-text-in-bright = "no";
          word-delimiters = '',│`|:"'()[]{}<>'';
          font = with config.stylix.fonts; mkForce "${monospace.name}:pixelsize=16";
          font-bold = with config.stylix.fonts; "${monospace.name}:pixelsize=16";
          line-height = "18px";
          # letter-spacing = -0.1;
          vertical-letter-offset = "-1px";
          selection-target = "primary";
          shell = "${pkgs.fish}/bin/fish";
          term = "xterm-256color";
        };

        cursor = {
          # style = "underline";
          style = "beam";
          beam-thickness = 2;
        };

        scrollback = {
          lines = 10000;
        };

        bell = {
          urgent = "yes";
          notify = "yes";
          command = "notify-send bell";
          command-focused = "no";
        };

        url = {
          launch = "xdg-open \${url}";
          label-letters = "sadfjklewcmpgh";
          osc8-underline = "url-mode";
          protocols = "http, https, ftp, ftps, file, gemini, gopher, irc, ircs";

          uri-characters = ''
            abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.,~:;/?#@!$&%*+="'()[]'';
        };

        mouse = {
          hide-when-typing = "yes";
        };

        mouse-bindings = {
          select-extend = "none";
          primary-paste = "BTN_RIGHT";
        };
      };
    };
  };
}
