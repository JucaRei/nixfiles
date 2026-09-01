{
  config,
  lib,
  pkgs,
  useNixGL ? false,
  desktop ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool listOf str;
  cfg = config.desktop.bspwm;

  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);
in
{
  options.desktop.bspwm = {
    enable = mkOption {
      type = bool;
      default = (desktop == "bspwm");
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
      profilePath = ".xprofile";
      windowManager = {
        bspwm = {
          enable = true;
          package = nixGLWrapper pkgs.bspwm;
          monitors = { };
          settings = {
            split_ratio = 0.52;
            border_width = 2;
            window_gap = 10; # Gaps arejados estilo Hyprland
            top_padding = 34; # Altura da Polybar
            bottom_padding = 6;
            left_padding = 6;
            right_padding = 6;
            normal_border_color = "#181825"; # Catppuccin Mantle escuro
            active_border_color = "#313244"; # Catppuccin Surface0
            focused_border_color = "#cba6f7"; # Catppuccin Mauve (Glow característico do Hyprland)
            presel_feedback_color = "#f2cdcd"; # Catppuccin Flamingo
          };
          rules = {
            # --- Utilitários de Sistema, Áudio e Vídeo ---
            "Lxappearance" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "lxappearance" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Galculator" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "galculator" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Gnome-calculator" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Qalculate-gtk" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Pavucontrol" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "pavucontrol" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Arandr" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "arandr" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Nitrogen" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "nitrogen" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Nm-connection-editor" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "nm-connection-editor" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Blueman-manager" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Blueman-adapters" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "GParted" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "gparted" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Xfce4-taskmanager" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "File-roller" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Engrampa" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Catfish" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Flameshot" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "feh" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Viewnior" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Kvantum Manager" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Font-manager" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Thunar" = {
              # Diálogos internos do Thunar (Progresso, Propriedades, Substituição)
              # Janelas normais do Thunar serão tiled, mas diálogos com class/instance serão floating
            };
          };
          extraConfig = ''
            # Regras extras de janelas flutuantes para diálogos e seletores do sistema
            bspc rule -a "*:*:Open File" state=floating center=on follow=on
            bspc rule -a "*:*:Save As" state=floating center=on follow=on
            bspc rule -a "*:*:File Operation Progress" state=floating center=on follow=on
            bspc rule -a "*:*:Preferences" state=floating center=on follow=on
            bspc rule -a "*:*:Confirm to replace files" state=floating center=on follow=on

            # Configurar workspaces 1 a 10 (onde 0 = 10) em todos os monitores conectados
            for m in $(bspc query -M); do
              bspc monitor "$m" -d I II III IV V VI VII VIII IX X
            done

            # Iniciar daemon de atalhos de teclado (SXHKD)
            pkill -x sxhkd || true
            ${pkgs.sxhkd}/bin/sxhkd &

            # Cursor padrão
            xsetroot -cursor_name left_ptr &

            # Importar variáveis de ambiente para serviços do usuário
            systemctl --user import-environment DISPLAY XAUTHORITY

            # Agente de autenticação Polkit
            ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &

            # Wallpaper / Fundo
            xsetroot -solid '#1e1e2e' &

            # Applet de Rede (após importar DISPLAY)
            ${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable &

            # Mouse bindings para mover e redimensionar janelas flutuantes
            bspc config pointer_modifier mod4
            bspc config pointer_action1 move
            bspc config pointer_action2 resize_side
            bspc config pointer_action3 resize_corner

            # Foco segue o ponteiro
            bspc config focus_follows_pointer true

            # Configurar Touchpad: Natural Scrolling (estilo macOS), Tapping e Clickfinger
            if command -v ${pkgs.xinput}/bin/xinput >/dev/null 2>&1; then
              for id in $(${pkgs.xinput}/bin/xinput list --id-only 2>/dev/null); do
                if ${pkgs.xinput}/bin/xinput list-props "$id" 2>/dev/null | grep -q "libinput Natural Scrolling Enabled"; then
                  ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Natural Scrolling Enabled" 1 2>/dev/null || true
                  ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Tapping Enabled" 1 2>/dev/null || true
                  ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Click Method Enabled" 0 1 2>/dev/null || true
                fi
              done
            fi

            # Iniciar daemon de gestos do Touchpad (3 dedos para alternar workspaces)
            pkill -x libinput-gestures || true
            ${pkgs.libinput-gestures}/bin/libinput-gestures &

            # Regras customizadas adicionais
            ${lib.concatStringsSep "\n" cfg.rules}

            ${cfg.extraConfig}
          '';
        };
      };
    };

    xdg.configFile."libinput-gestures.conf".text = ''
      # Gestos de 4 dedos para trocar de Desktop
      gesture swipe left 4  ${pkgs.bspwm}/bin/bspc desktop -f next.local
      gesture swipe right 4 ${pkgs.bspwm}/bin/bspc desktop -f prev.local
      # Gestos de 3 dedos para navegação no navegador
      gesture swipe left 3  ${pkgs.xdotool}/bin/xdotool key alt+Left
      gesture swipe right 3 ${pkgs.xdotool}/bin/xdotool key alt+Right
      # Outros
      gesture swipe up 3 ${pkgs.rofi}/bin/rofi -show drun
      gesture swipe down 3 ${pkgs.bspwm}/bin/bspc node -c
    '';

    home = {
      packages = with pkgs; [
        libinput-gestures
        wmctrl
        xdotool
        tdrop
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
