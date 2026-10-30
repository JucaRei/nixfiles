{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  desktop ? null,
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
  options.desktop.bspwm = {
    enable = lib.my.mkBool (desktop == "bspwm") "Enable bspwm window manager";

    extraConfig = lib.my.mkStr "" "Additional bspwmrc configuration to append";

    modifierKey = lib.my.mkStr (config.desktop.modifierKey or "Super"
    ) "Tecla modificadora principal do BSPWM (ex: 'Super', 'Alt', 'Ctrl').";

    extraKeybindings =
      lib.my.mkOpt (lib.types.attrsOf lib.types.str) { }
        "Atalhos adicionais ou personalizados do SXHKD definidos no host.";

    rules = lib.my.mkListOf lib.types.str [ ] "bspwm rules for specific applications";
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
            "Blueman-assistant" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Blueman-services" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Blueman-sendto" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Stalonetray" = {
              state = "floating";
              sticky = true;
              border = false;
              manage = false;
            };
            "stalonetray" = {
              state = "floating";
              sticky = true;
              border = false;
              manage = false;
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
            "scrcpy" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "Scrcpy" = {
              state = "floating";
              center = true;
              follow = true;
            };
            ".scrcpywrap" = {
              state = "floating";
              center = true;
              follow = true;
            };
            ".scrcpy-wrapped" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "scrcpy-wrapped" = {
              state = "floating";
              center = true;
              follow = true;
            };
            "bspwm-scratch" = {
              state = "floating";
              sticky = true;
            };
          };
          extraConfig = ''
            # Script dinâmico de regras externas para diálogos e seletores de arquivos/pastas
            bspc config external_rules_command "${externalRulesScript}"

            # Regras para scrcpy (todas as variações de nomes/wrappers)
            bspc rule -a "*scrcpy*" state=floating center=on follow=on
            bspc rule -a "*Scrcpy*" state=floating center=on follow=on
            bspc rule -a ".scrcpywrap" state=floating center=on follow=on
            bspc rule -a ".scrcpy-wrapped" state=floating center=on follow=on
            bspc rule -a "scrcpy-wrapped" state=floating center=on follow=on

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
            bspc rule -a "*:pop-up" state=floating center=on follow=on
            bspc rule -a "*:*:*Sign in*" state=floating center=on follow=on
            bspc rule -a "*:*:*Fazer login*" state=floating center=on follow=on
            bspc rule -a "*:*:*Contas do Google*" state=floating center=on follow=on
            bspc rule -a "*:*:*Google Accounts*" state=floating center=on follow=on
            bspc rule -a "*:*:*OAuth*" state=floating center=on follow=on
            bspc rule -a "*:*:*Authorize*" state=floating center=on follow=on
            bspc rule -a "*:*:*Bitwarden*" state=floating center=on follow=on
            bspc rule -a "xdg-desktop-portal-gtk" state=floating center=on rectangle=850x550+0+0 follow=on
            bspc rule -a "Xdg-desktop-portal-gtk" state=floating center=on rectangle=850x550+0+0 follow=on

            # Aplicar resolução e layout de telas declarativos antes de distribuir os workspaces
            if command -v setup-monitors >/dev/null 2>&1; then
              setup-monitors || true
            fi

            # Distribuir workspaces de acordo com a topologia de monitores:
            # - Em setup multi-monitor: monitor principal recebe 1 3 5 7 9 e o secundário recebe 2 4 6 8 0
            # - Em monitor único: recebe todos os workspaces 1 2 3 4 5 6 7 8 9 0
            primary_mon=$(xrandr --query 2>/dev/null | grep " connected primary" | cut -d" " -f1)
            [ -z "$primary_mon" ] && primary_mon=$(bspc query -M -m primary --names 2>/dev/null || true)
            [ -z "$primary_mon" ] && primary_mon=$(bspc query -M --names 2>/dev/null | head -n1)

            other_mons=$(bspc query -M --names 2>/dev/null | grep -v "^$primary_mon$" || true)

            if [ -n "$primary_mon" ] && [ -n "$other_mons" ]; then
              bspc wm -O "$primary_mon" $other_mons 2>/dev/null || true
              bspc monitor "$primary_mon" -d 1 3 5 7 9
              sec_mon=$(echo "$other_mons" | head -n1)
              bspc monitor "$sec_mon" -d 2 4 6 8 0
              for extra in $(echo "$other_mons" | tail -n +2); do
                bspc monitor "$extra" -d 1 2 3 4 5
              done
            elif [ -n "$primary_mon" ]; then
              bspc monitor "$primary_mon" -d 1 2 3 4 5 6 7 8 9 0
            fi

            # Carregar bibliotecas de driver gráfico se presentes (essencial para drivers legados como NVIDIA 340)
            if [ -d /run/opengl-driver/lib ] && [ -f /run/opengl-driver/lib/libGL.so.1 ]; then
              export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            fi

            # Configuração do teclado herdada declarativamente de home.keyboard
            ${lib.optionalString (config.home.keyboard != null) ''
              ${pkgs.setxkbmap}/bin/setxkbmap \
                ${
                  lib.optionalString (config.home.keyboard.model != null) "-model '${config.home.keyboard.model}'"
                } \
                ${
                  lib.optionalString (config.home.keyboard.layout != null) "-layout '${config.home.keyboard.layout}'"
                } \
                ${
                  lib.optionalString (
                    config.home.keyboard.variant != null
                  ) "-variant '${config.home.keyboard.variant}'"
                } \
                ${
                  lib.concatMapStringsSep " " (opt: "-option '${opt}'") (config.home.keyboard.options or [ ])
                } || true
            ''}

            # Carregar recursos do X11 (incluindo tema e tamanho de cursor Xcursor)
            [ -f "$HOME/.Xresources" ] && ${pkgs.xrdb}/bin/xrdb -merge "$HOME/.Xresources" || true


            # Propagar variáveis do tema declarativo para sessão e aplicações
            export GTK_THEME="${config.gtk.theme.name}"
            export XCURSOR_THEME="${config.desktop.theme.cursor.name}"
            export XCURSOR_SIZE="${toString config.desktop.theme.cursor.size}"

            # Iniciar daemon de atalhos de teclado (SXHKD) a partir de $HOME
            pkill -x sxhkd || true
            (cd "$HOME" && ${pkgs.sxhkd}/bin/sxhkd) &

            # Propagação do ambiente gráfico para D-Bus e Systemd do usuário (essencial para XDG Portals e Flatpaks)
            export XDG_CURRENT_DESKTOP="bspwm"
            export XDG_SESSION_DESKTOP="bspwm"
            export XDG_SESSION_TYPE="x11"

            if command -v dbus-update-activation-environment >/dev/null 2>&1; then
              dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE PATH XDG_DATA_DIRS LD_LIBRARY_PATH LIBVA_DRIVER_NAME VDPAU_DRIVER GTK_THEME XCURSOR_THEME XCURSOR_SIZE GTK_IM_MODULE QT_IM_MODULE XMODIFIERS SDL_IM_MODULE GLFW_IM_MODULE
            fi
            systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE PATH XDG_DATA_DIRS LD_LIBRARY_PATH LIBVA_DRIVER_NAME VDPAU_DRIVER GTK_THEME XCURSOR_THEME XCURSOR_SIZE GTK_IM_MODULE QT_IM_MODULE XMODIFIERS SDL_IM_MODULE GLFW_IM_MODULE 2>/dev/null || true
            systemctl --user start graphical-session.target 2>/dev/null || true

            # Reiniciar Portals para garantir sincronia com as variáveis gráficas recém-importadas
            systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service 2>/dev/null || true

            # Iniciar daemon de método de entrada (Fcitx5) se disponível
            if command -v fcitx5 >/dev/null 2>&1; then
              pkill -x fcitx5 || true
              fcitx5 -d &
            fi

            # Iniciar compositor Picom se habilitado
            ${lib.optionalString config.desktop.bspwm.picom.enable ''
              pkill -x picom || true
              systemctl --user restart picom 2>/dev/null || (${nixGLWrapper pkgs.picom}/bin/picom -b 2>/dev/null || true) &
            ''}

            # Iniciar daemon de notificações Dunst se habilitado
            ${lib.optionalString config.desktop.bspwm.dunst.enable ''
              pkill -f notification-daemon 2>/dev/null || true
              pkill -f xfce4-notifyd 2>/dev/null || true
              pkill -f mate-notification-daemon 2>/dev/null || true
              pkill -f mako 2>/dev/null || true
              systemctl --user reset-failed dunst 2>/dev/null || true
              systemctl --user restart dunst 2>/dev/null || true
              sleep 0.2
              if ! ${pkgs.dunst}/bin/dunstctl is-paused >/dev/null 2>&1; then
                pkill -x dunst 2>/dev/null || true
                nohup ${pkgs.dunst}/bin/dunst >/dev/null 2>&1 &
              fi
            ''}

            # Iniciar barra de status Polybar se habilitada
            ${lib.optionalString config.desktop.bspwm.polybar.enable ''
              systemctl --user restart polybar 2>/dev/null || (
                if command -v polybar-launch >/dev/null 2>&1; then
                  polybar-launch &
                else
                  ${pkgs.polybar}/bin/polybar --reload main &
                fi
              ) &
            ''}

            # Matar processos residuais de bsp-layout watcher se existirem
            pkill -f "bsp-layout.*watch" 2>/dev/null || true

            # Iniciar daemon de bloqueio de tela (xss-lock) e configurar inatividade (XSS / DPMS)
            ${lib.optionalString (config.desktop.bspwm.lock.enable or true) ''
              if [ "${toString (config.desktop.bspwm.lock.timeout or 600)}" -gt 0 ]; then
                ${pkgs.xset}/bin/xset s "${toString (config.desktop.bspwm.lock.timeout or 600)}" "${
                  toString (config.desktop.bspwm.lock.timeout or 600)
                }" 2>/dev/null || true
                ${pkgs.xset}/bin/xset +dpms dpms "${toString (config.desktop.bspwm.lock.timeout or 600)}" "${
                  toString (config.desktop.bspwm.lock.dpmsTimeout or 900)
                }" "${toString ((config.desktop.bspwm.lock.dpmsTimeout or 900) + 300)}" 2>/dev/null || true
              else
                ${pkgs.xset}/bin/xset s off 2>/dev/null || true
              fi

              systemctl --user restart xss-lock 2>/dev/null || true
              sleep 0.2
              if ! systemctl --user is-active --quiet xss-lock 2>/dev/null; then
                pkill -x xss-lock 2>/dev/null || true
                ${pkgs.xss-lock}/bin/xss-lock --transfer-sleep-lock -- ${config.desktop.bspwm.lock.lockScript}/bin/bspwm-lock --nofork &
              fi
            ''}

            # Agente de autenticação Polkit
            ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &

            # Wallpaper / Fundo e Cursor padrão (garante left_ptr mesmo com fundo sólido)
            xsetroot -solid '${config.desktop.theme.colors.bg}' -cursor_name left_ptr &

            ${lib.optionalString (config.desktop.wallpaper.enable or false) ''
              # Inicializar wallpaper agnóstico
              if command -v set-wallpaper >/dev/null 2>&1; then
                set-wallpaper ${
                  if (config.desktop.wallpaper.randomOnStart or false) then "--random" else "--restore"
                } --quiet &
                ${lib.optionalString (config.desktop.wallpaper.interval != null) ''
                  # Iniciar timer de rotação periódica (systemd timer com fallback para daemon)
                  (
                    systemctl --user start wallpaper-rotate.timer 2>/dev/null || true
                    sleep 0.5
                    if ! systemctl --user is-active --quiet wallpaper-rotate.timer 2>/dev/null; then
                      pkill -f "set-wallpaper.*--(timer|daemon)" 2>/dev/null || true
                      set-wallpaper --timer "${config.desktop.wallpaper.interval}" --quiet &
                    fi
                  ) &
                ''}
              fi
            ''}

            # Applet de Rede desativado para manter o tray limpo apenas para apps externos (Wi-Fi gerenciado via Polybar/Rofi)
            # ${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable &

            # Applet Bluetooth (fornece agente de autenticação D-Bus para PIN/Passkey)
            if command -v blueman-applet >/dev/null 2>&1; then
              pkill -x blueman-applet || true
              blueman-applet &
            elif [ -x "${pkgs.blueman}/bin/blueman-applet" ]; then
              pkill -x blueman-applet || true
              ${pkgs.blueman}/bin/blueman-applet &
            fi

            ${lib.optionalString
              (config.desktop.bspwm.polybar.enable && config.desktop.bspwm.polybar.tray.enable)
              ''
                # Bandeja do sistema (Stalonetray)
                if command -v stalonetray >/dev/null 2>&1; then
                  pkill -x stalonetray || true
                  stalonetray &
                elif [ -x "${pkgs.stalonetray}/bin/stalonetray" ]; then
                  pkill -x stalonetray || true
                  ${pkgs.stalonetray}/bin/stalonetray &
                fi
              ''
            }

            # Auto-trust de dispositivos Bluetooth pareados (elimina bloqueios de autorização do BlueZ)
            (
              sleep 2
              if command -v bluetoothctl >/dev/null 2>&1; then
                for dev in $(bluetoothctl devices Paired 2>/dev/null | awk '{print $2}'); do
                  bluetoothctl trust "$dev" >/dev/null 2>&1 || true
                done
              fi
            ) &

            # Mouse bindings para mover e redimensionar janelas flutuantes
            bspc config pointer_modifier ${pointerMod}
            bspc config pointer_action1 move
            bspc config pointer_action2 resize_side
            bspc config pointer_action3 resize_corner

            # Daemon para trazer a janela selecionada/focada sempre para frente (auto-raise em janelas flutuantes e lado a lado)
            pkill -f bspwm-auto-raise || true
            ${autoRaiseScript} &


            # Configurar Touchpad vs Mouse:
            # - Touchpad: Natural Scrolling, Tapping, Clickfinger, Perfil de Aceleração e Velocidade do Ponteiro
            # - Mouse: Natural Scrolling DESATIVADO (rolagem padrão tradicional)
            if command -v ${pkgs.xinput}/bin/xinput >/dev/null 2>&1; then
              for id in $(${pkgs.xinput}/bin/xinput list --id-only 2>/dev/null); do
                dev_name=$(${pkgs.xinput}/bin/xinput list --name-only "$id" 2>/dev/null | tr '[:upper:]' '[:lower:]')
                has_tapping=$(${pkgs.xinput}/bin/xinput list-props "$id" 2>/dev/null | grep -c "libinput Tapping Enabled" || true)

                if echo "$dev_name" | grep -q "touchpad" || [ "$has_tapping" -gt 0 ]; then
                  ${lib.optionalString config.desktop.touchpad.enable ''
                    ${lib.optionalString config.desktop.touchpad.naturalScrolling ''
                      ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Natural Scrolling Enabled" 1 2>/dev/null || true
                    ''}
                    ${lib.optionalString (!config.desktop.touchpad.naturalScrolling) ''
                      ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Natural Scrolling Enabled" 0 2>/dev/null || true
                    ''}
                    ${lib.optionalString config.desktop.touchpad.tapping ''
                      ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Tapping Enabled" 1 2>/dev/null || true
                    ''}
                    ${lib.optionalString (config.desktop.touchpad.clickMethod == "clickfinger") ''
                      ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Click Method Enabled" 0 1 2>/dev/null || true
                    ''}
                    ${lib.optionalString (config.desktop.touchpad.clickMethod == "buttonareas") ''
                      ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Click Method Enabled" 1 0 2>/dev/null || true
                    ''}
                    ${lib.optionalString (config.desktop.touchpad.accelProfile == "adaptive") ''
                      ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Accel Profile Enabled" 1 0 2>/dev/null || true
                    ''}
                    ${lib.optionalString (config.desktop.touchpad.accelProfile == "flat") ''
                      ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Accel Profile Enabled" 0 1 2>/dev/null || true
                    ''}
                    ${lib.optionalString (config.desktop.touchpad.speed != null) ''
                      ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Accel Speed" ${toString config.desktop.touchpad.speed} 2>/dev/null || true
                    ''}
                  ''}
                else
                  if ${pkgs.xinput}/bin/xinput list-props "$id" 2>/dev/null | grep -q "libinput Natural Scrolling Enabled"; then
                    ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Natural Scrolling Enabled" 0 2>/dev/null || true
                  fi
                fi
              done
            fi

            ${lib.optionalString config.desktop.touchpad.enable ''
              # Iniciar daemon de gestos do Touchpad
              systemctl --user restart libinput-gestures 2>/dev/null || (pkill -f libinput-gestures || true; pkill -f libinput-debug-events || true; sleep 0.2; ${pkgs.libinput-gestures}/bin/libinput-gestures -c ~/.config/libinput-gestures.conf &)
            ''}

            # Regras customizadas adicionais
            ${lib.concatStringsSep "\n" cfg.rules}

            ${cfg.extraConfig}
          '';
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

    systemd.user.services.libinput-gestures = mkIf config.desktop.touchpad.enable {
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

    systemd.user.services.bspwm-auto-raise = {
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

    home = {
      activation.reloadBspwmColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ${pkgs.procps}/bin/pgrep -x bspwm >/dev/null 2>&1; then
          ${pkgs.bspwm}/bin/bspc config normal_border_color "${config.desktop.theme.colors.border}" 2>/dev/null || true
          ${pkgs.bspwm}/bin/bspc config active_border_color "${config.desktop.theme.colors.surfaceAlt}" 2>/dev/null || true
          ${pkgs.bspwm}/bin/bspc config focused_border_color "${config.desktop.theme.colors.accent}" 2>/dev/null || true
          ${pkgs.bspwm}/bin/bspc config presel_feedback_color "${config.desktop.theme.colors.accent}" 2>/dev/null || true
        fi
      '';

      activation.reloadBspwmAutoRaise = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if systemctl --user is-active --quiet graphical-session.target 2>/dev/null || pgrep -f bspwm >/dev/null 2>&1; then
          systemctl --user daemon-reload 2>/dev/null || true
          systemctl --user restart bspwm-auto-raise.service 2>/dev/null || (${autoRaiseScript} &)
        fi
      '';

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
