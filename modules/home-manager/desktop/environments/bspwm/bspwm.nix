# modules/home-manager/desktop/environments/bspwm/bspwm.nix
# Gerenciador de janelas BSPWM: integração X11, daemons systemd e hooks de ativação.
{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.bspwm;

  normMod =
    let
      k = lib.toLower (cfg.modifierKey or "super");
    in
    if k == "super" || k == "mod4" then
      "Super"
    else if k == "alt" || k == "mod1" then
      "Alt"
    else if k == "ctrl" || k == "control" then
      "Ctrl"
    else
      "Super";

  pointerMod =
    if normMod == "Alt" then
      "mod1"
    else if normMod == "Ctrl" then
      "control"
    else
      "mod4";

  writeShellApp =
    args:
    pkgs.writeShellApplication (
      args
      // {
        bashOptions = args.bashOptions or [ ];
        excludeShellChecks = (args.excludeShellChecks or [ ]) ++ [
          "SC1091"
          "SC2001"
          "SC2005"
          "SC2012"
          "SC2015"
          "SC2016"
          "SC2028"
          "SC2034"
          "SC2046"
          "SC2059"
          "SC2076"
          "SC2086"
          "SC2089"
          "SC2090"
          "SC2119"
          "SC2120"
          "SC2126"
          "SC2154"
          "SC2155"
          "SC2181"
          "SC2183"
          "SC2206"
          "SC2207"
          "SC2221"
          "SC2222"
        ];
      }
    );

  externalRulesScriptPkg = writeShellApp {
    name = "bspwm-external-rules";
    runtimeInputs = [
      pkgs.xprop
      pkgs.gnugrep
    ];
    text = builtins.readFile ./scripts/bspwm-external-rules.sh;
  };
  externalRulesScript = lib.getExe externalRulesScriptPkg;

  browserTabSwitchPkg = writeShellApp {
    name = "browser-tab-switch";
    runtimeInputs = [
      pkgs.xdotool
      pkgs.xprop
      pkgs.coreutils
    ];
    text = builtins.readFile ./scripts/browser-tab-switch.sh;
  };
  browserTabSwitch = lib.getExe browserTabSwitchPkg;

  autoRaiseScriptPkg = writeShellApp {
    name = "bspwm-auto-raise";
    runtimeInputs = [
      pkgs.bspwm
      pkgs.coreutils
    ];
    text = builtins.readFile ./scripts/bspwm-auto-raise.sh;
  };
  autoRaiseScript = lib.getExe autoRaiseScriptPkg;

in
{
  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      profilePath = ".xprofile";
      windowManager = {
        bspwm = {
          enable = true;
          package = nixGLWrapper pkgs.bspwm;
          monitors = { };
          settings = {
            split_ratio = 0.51;
            border_width = 2;
            single_monocle = true;
            automatic_scheme = "longest_side";
            initial_polarity = "second_child";
            window_gap = 5; # Gaps arejados estilo Hyprland
            top_padding = 42; # Altura da Polybar flutuante (32px) + gap superior (6px) + respiro (4px)
            bottom_padding = 4;
            left_padding = 4;
            right_padding = 4;
            focus_follows_pointer = false;
            pointer_follows_focus = false;
            click_to_focus = "any";
            normal_border_color = config.desktop.theme.colors.border;
            active_border_color = config.desktop.theme.colors.surfaceAlt;
            focused_border_color = config.desktop.theme.colors.accent;
            presel_feedback_color = config.desktop.theme.colors.accent;
          };
          extraConfig = import ./_bspwmrc.nix {
            inherit
              config
              lib
              pkgs
              nixGLWrapper
              pointerMod
              externalRulesScript
              autoRaiseScript
              ;
          };
        };
      };
    };

    xdg.configFile."libinput-gestures.conf" = mkIf config.desktop.touchpad.enable {
      text = ''
        # Gestos de 3 dedos para trocar de Desktop (Workspaces)
        gesture swipe left 3  ${pkgs.bspwm}/bin/bspc desktop -f next.local
        gesture swipe right 3 ${pkgs.bspwm}/bin/bspc desktop -f prev.local

        # Gestos de 4 dedos para alternar abas do navegador (se estiver em uso)
        gesture swipe left 4  ${browserTabSwitch} next
        gesture swipe right 4 ${browserTabSwitch} prev

        # Outros gestos de 3 dedos
        gesture swipe up 3 ${pkgs.rofi}/bin/rofi -show drun
        gesture swipe down 3 ${pkgs.bspwm}/bin/bspc node -c
      '';
    };

    systemd.user.services = {
      libinput-gestures = mkIf config.desktop.touchpad.enable {
        Unit = {
          Description = "Touchpad gesture daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures -c %h/.config/libinput-gestures.conf";
          Restart = "on-failure";
          RestartSec = 3;
          PassEnvironment = [
            "DISPLAY"
            "XAUTHORITY"
          ];
          Environment = [
            "PATH=${
              lib.makeBinPath [
                pkgs.coreutils
                pkgs.bspwm
                pkgs.xdotool
                pkgs.rofi
                pkgs.xprop
              ]
            }:/run/current-system/sw/bin"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      bspwm-auto-raise = {
        Unit = {
          Description = "BSPWM Auto-Raise Window Daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${autoRaiseScript}";
          Restart = "always";
          RestartSec = 1;
          PassEnvironment = [
            "DISPLAY"
            "XAUTHORITY"
          ];
          Environment = [
            "PATH=${
              lib.makeBinPath [
                pkgs.coreutils
                pkgs.bspwm
              ]
            }:/run/current-system/sw/bin"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      bsp-layout = {
        Unit = {
          Description = "BSPWM Dynamic Layout Manager Daemon (bsp-layout)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.bsp-layout}/bin/bsp-layout watch";
          Restart = "on-failure";
          RestartSec = 2;
          PassEnvironment = [
            "DISPLAY"
            "XAUTHORITY"
            "XDG_RUNTIME_DIR"
          ];
          Environment = [
            "PATH=${
              lib.makeBinPath [
                pkgs.coreutils
                pkgs.bspwm
                pkgs.jq
                pkgs.gawk
                pkgs.gnugrep
                pkgs.procps
              ]
            }:/run/current-system/sw/bin"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };

    home = {
      activation = {
        reloadBspwmColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if ${pkgs.procps}/bin/pgrep -x bspwm >/dev/null 2>&1; then
            ${pkgs.bspwm}/bin/bspc config normal_border_color "${config.desktop.theme.colors.border}" 2>/dev/null || true
            ${pkgs.bspwm}/bin/bspc config active_border_color "${config.desktop.theme.colors.surfaceAlt}" 2>/dev/null || true
            ${pkgs.bspwm}/bin/bspc config focused_border_color "${config.desktop.theme.colors.accent}" 2>/dev/null || true
            ${pkgs.bspwm}/bin/bspc config presel_feedback_color "${config.desktop.theme.colors.accent}" 2>/dev/null || true
          fi
        '';

        reloadBspwmAutoRaise = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if systemctl --user is-active --quiet graphical-session.target 2>/dev/null || pgrep -f bspwm >/dev/null 2>&1; then
            systemctl --user daemon-reload 2>/dev/null || true
            systemctl --user restart bspwm-auto-raise.service 2>/dev/null || (${autoRaiseScript} &)
          fi
        '';

        reloadBspLayout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if systemctl --user is-active --quiet graphical-session.target 2>/dev/null || ${pkgs.procps}/bin/pgrep -x bspwm >/dev/null 2>&1; then
            systemctl --user daemon-reload 2>/dev/null || true
            systemctl --user restart bsp-layout.service 2>/dev/null || (${pkgs.bsp-layout}/bin/bsp-layout watch &)
          fi
        '';
      };

      packages = with pkgs; [
        libinput-gestures
        wmctrl
        xdotool
        xdo
        xprop
        xkb-switch
      ];

      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        GLFW_IM_MODULE = "ibus";
        TERM = "alacritty"; # Compatível com o Alacritty
        QT_STYLE_OVERRIDE = lib.mkDefault "kvantum";
        LOG_ICONS = "true";
      };

      shellAliases = {
        is_picom_on = "pgrep -x 'picom' > /dev/null && echo 'on' || echo 'off'";
      };
    };
  };
}
