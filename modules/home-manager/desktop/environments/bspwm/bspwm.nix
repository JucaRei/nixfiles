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

  externalRulesScript = pkgs.writeShellScript "bspwm-external-rules" ''
    wid="$1"
    class="$2"
    instance="$3"
    consequences="$4"

    case "$class" in
      *xdg-desktop-portal*|*Xdg-desktop-portal*)
        echo "state=floating center=on rectangle=850x550+0+0 follow=on"
        exit 0
        ;;
    esac

    # Consultar propriedades X11 da nova janela
    PROPS="$(${pkgs.xprop}/bin/xprop -id "$wid" WM_NAME _NET_WM_NAME WM_WINDOW_ROLE _NET_WM_WINDOW_TYPE 2>/dev/null)"
    [ -z "$PROPS" ] && exit 0

    # 1. Diálogos nativos de seleção de arquivos (GtkFileChooserDialog) -> tamanho compacto e centralizado
    if echo "$PROPS" | ${pkgs.gnugrep}/bin/grep -q 'WM_WINDOW_ROLE.*GtkFileChooserDialog'; then
      echo "state=floating center=on rectangle=850x550+0+0 follow=on"
      exit 0
    fi

    # 2. Títulos de janelas de seleção de pastas e arquivos (VSCode, navegadores, Electron, GTK, Qt)
    if echo "$PROPS" | ${pkgs.gnugrep}/bin/grep -Ei -q '(WM_NAME|_NET_WM_NAME).*"(Open Folder|Abrir [Pp]asta|Open File|Abrir [Aa]rquivo|Select a? [Ff]older|Selecionar .*pasta|Select a? [Ff]ile|Selecionar .*arquivo|Choose [Ff]older|Escolher [Pp]asta|Choose [Ff]ile|Escolher [Aa]rquivo|Save As|Salvar [Cc]omo|Save File|Salvar [Aa]rquivo|File Upload|Enviar [Aa]rquivo|Open Workspace|Abrir [Ee]spaço|Add Folder|Adicionar [Pp]asta)'; then
      echo "state=floating center=on rectangle=850x550+0+0 follow=on"
      exit 0
    fi

    # 3. Janelas modais/diálogos genéricos -> flutuantes e centralizadas preservando tamanho padrão
    if echo "$PROPS" | ${pkgs.gnugrep}/bin/grep -q '_NET_WM_WINDOW_TYPE_DIALOG'; then
      echo "state=floating center=on follow=on"
      exit 0
    fi
  '';

  browserTabSwitch = pkgs.writeShellScript "browser-tab-switch" ''
    action="$1" # "next" or "prev"
    wid="$(${pkgs.xdotool}/bin/xdotool getactivewindow 2>/dev/null)"
    [ -z "$wid" ] && exit 0
    wclass="$(${pkgs.xprop}/bin/xprop -id "$wid" WM_CLASS 2>/dev/null | ${pkgs.coreutils}/bin/tr '[:upper:]' '[:lower:]')"
    case "$wclass" in
      *firefox*|*chrome*|*chromium*|*brave*|*opera*|*vivaldi*|*edge*|*zen*|*code*|*alacritty*)
        if [ "$action" = "next" ]; then
          ${pkgs.xdotool}/bin/xdotool key --clearmodifiers ctrl+Page_Down
        else
          ${pkgs.xdotool}/bin/xdotool key --clearmodifiers ctrl+Page_Up
        fi
        ;;
    esac
  '';
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
            "xdg-desktop-portal-gtk" = {
              state = "floating";
              center = true;
              follow = true;
              rectangle = "850x550+0+0";
            };
            "Xdg-desktop-portal-gtk" = {
              state = "floating";
              center = true;
              follow = true;
              rectangle = "850x550+0+0";
            };
          };
          extraConfig = ''
            # Script dinâmico de regras externas para diálogos e seletores de arquivos/pastas
            bspc config external_rules_command "${externalRulesScript}"

            # Regras estáticas para seletores de arquivos e pastas (tamanho compacto e centralizado)
            bspc rule -a "*:*:Open Folder" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Abrir pasta" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Open File" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Abrir arquivo" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Select Folder" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Selecionar pasta" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Select a Folder" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Selecionar uma pasta" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Choose Folder" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Escolher pasta" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Save As" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Salvar como" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Save File" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:Salvar arquivo" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "*:*:File Operation Progress" state=floating center=on follow=on
            bspc rule -a "*:*:Preferences" state=floating center=on follow=on
            bspc rule -a "*:*:Confirm to replace files" state=floating center=on follow=on
            bspc rule -a "xdg-desktop-portal-gtk" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "Xdg-desktop-portal-gtk" state=floating center=on rectangle=850x550+0+0 follow=on

            # Configurar workspaces 1 a 10 (onde 0 = 10) em todos os monitores conectados
            for m in $(bspc query -M); do
              bspc monitor "$m" -d I II III IV V VI VII VIII IX X
            done

            # Carregar bibliotecas de driver gráfico se presentes (essencial para drivers legados como NVIDIA 340)
            if [ -d /run/opengl-driver/lib ] && [ -f /run/opengl-driver/lib/libGL.so.1 ]; then
              export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            fi

            # Iniciar daemon de atalhos de teclado (SXHKD)
            pkill -x sxhkd || true
            ${pkgs.sxhkd}/bin/sxhkd &

            # Cursor padrão
            xsetroot -cursor_name left_ptr &

            # Importar variáveis de ambiente para serviços do usuário
            systemctl --user import-environment DISPLAY XAUTHORITY LD_LIBRARY_PATH LIBVA_DRIVER_NAME VDPAU_DRIVER
            systemctl --user start graphical-session.target 2>/dev/null || true

            # Iniciar compositor Picom se habilitado
            ${lib.optionalString config.desktop.bspwm.picom.enable ''
              pkill -x picom || true
              systemctl --user restart picom 2>/dev/null || (${pkgs.picom}/bin/picom -b 2>/dev/null || true) &
            ''}

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

            # Iniciar daemon de gestos do Touchpad
            systemctl --user restart libinput-gestures 2>/dev/null || (pkill -x libinput-gestures || true; ${pkgs.libinput-gestures}/bin/libinput-gestures -c ~/.config/libinput-gestures.conf &)

            # Regras customizadas adicionais
            ${lib.concatStringsSep "\n" cfg.rules}

            ${cfg.extraConfig}
          '';
        };
      };
    };

    xdg.configFile."libinput-gestures.conf".text = ''
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

    systemd.user.services.libinput-gestures = {
      Unit = {
        Description = "Touchpad gesture daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures -c %h/.config/libinput-gestures.conf";
        Restart = "on-failure";
        RestartSec = 3;
        Environment = [
          "PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.bspwm pkgs.xdotool pkgs.rofi pkgs.xprop ]}:/run/current-system/sw/bin"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    home = {
      packages = with pkgs; [
        libinput-gestures
        wmctrl
        xdotool
        tdrop
        xprop
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
