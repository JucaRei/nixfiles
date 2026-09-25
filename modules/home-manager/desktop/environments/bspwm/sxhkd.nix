{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool attrs;
  cfg = config.desktop.bspwm.sxhkd;
  fmCmd = config.system.programs.file-manager.activeCommand or "file-manager";
  fmName = config.system.programs.file-manager.activeName or "Gerenciador de Arquivos";

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

  mod =
    if normMod == "Alt" then
      "alt"
    else if normMod == "Ctrl" then
      "ctrl"
    else
      "super";

  altMod = if mod == "alt" then "super" else "alt";
  ctrlMod = if mod == "ctrl" then "super" else "ctrl";
  modDisplayName = normMod; # "Super", "Alt", "Ctrl"
  altDisplayName = if mod == "alt" then "Super" else "Alt";

  # --- Script de Notificação de Volume (Dunst OSD) ---
  volumeOsd = pkgs.writeShellScript "volume-osd" ''
    case "$1" in
      up)   ${pkgs.pamixer}/bin/pamixer -i 2 ;;
      down) ${pkgs.pamixer}/bin/pamixer -d 2 ;;
      mute) ${pkgs.pamixer}/bin/pamixer -t ;;
    esac

    vol=$(${pkgs.pamixer}/bin/pamixer --get-volume 2>/dev/null || echo "0")
    is_muted=$(${pkgs.pamixer}/bin/pamixer --get-mute 2>/dev/null || echo "false")

    if [ "$is_muted" = "true" ] || [ "$vol" -eq 0 ]; then
      ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "audio-volume-muted" -r 9991 -h int:value:0 -t 1500 "Volume: Mudo"
    else
      ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "audio-volume-high" -r 9991 -h int:value:"$vol" -t 1500 "Volume: $vol%"
    fi
  '';

  # --- Script de Notificação de Brilho da Tela (Dunst OSD) ---
  brightnessOsd = pkgs.writeShellScript "brightness-osd" ''
    # Identificar dispositivo de tela real (priorizar intel_backlight > nv_backlight > apple_backlight > acpi_video0)
    dev=""
    for d in intel_backlight nv_backlight apple_backlight acpi_video0; do
      if [ -d "/sys/class/backlight/$d" ]; then
        dev="$d"
        break
      fi
    done
    if [ -z "$dev" ] && [ -d /sys/class/backlight ]; then
      dev=$(ls -1 /sys/class/backlight 2>/dev/null | head -n1)
    fi

    dev_args=()
    if [ -n "$dev" ]; then
      dev_args=(-d "$dev")
    fi

    case "$1" in
      up)
        prev=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" get 2>/dev/null)
        ${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" set +2% >/dev/null 2>&1
        curr=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" set +1 >/dev/null 2>&1
        fi
        ;;
      down)
        prev=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" get 2>/dev/null)
        ${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" set 2%- >/dev/null 2>&1
        curr=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" get 2>/dev/null)
        if [ "$prev" = "$curr" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" set 1- >/dev/null 2>&1
        fi
        ;;
    esac

    val=$(${pkgs.brightnessctl}/bin/brightnessctl "''${dev_args[@]}" -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -n1)
    if [ -n "$val" ]; then
      ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "display-brightness" -r 9992 -h int:value:"$val" -t 1500 "Brilho da Tela: $val%"
    fi
  '';

  # --- Script de Controle e Notificação de Luz do Teclado (Logitech MX Keys / MacBook / Laptops) ---
  kbdBrightnessOsd = pkgs.writeShellScript "kbd-brightness-osd" ''
    # 1. Identificar dispositivo de iluminação de teclado via brightnessctl
    dev=""
    for candidate in "smc::kbd_backlight" "apple::kbd_backlight" "dell::kbd_backlight" "asus::kbd_backlight" "tpacpi::kbd_backlight"; do
      if ${pkgs.brightnessctl}/bin/brightnessctl -d "$candidate" info >/dev/null 2>&1; then
        dev="$candidate"
        break
      fi
    done

    if [ -z "$dev" ]; then
      dev=$(${pkgs.brightnessctl}/bin/brightnessctl --list 2>/dev/null | grep -E -m1 "kbd_backlight|keyboard" | cut -d\' -f2 || true)
    fi

    if [ -n "$dev" ]; then
      case "$1" in
        up)
          prev=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +5% >/dev/null 2>&1 || ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +1 >/dev/null 2>&1
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set +1 >/dev/null 2>&1
          fi
          ;;
        down)
          prev=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 5%- >/dev/null 2>&1 || ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 1- >/dev/null 2>&1
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" get 2>/dev/null)
          if [ "$prev" = "$curr" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 1- >/dev/null 2>&1
          fi
          ;;
        toggle)
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -n1)
          if [ "$curr" -gt 0 ] 2>/dev/null; then
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 0%
          else
            ${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" set 50%
          fi
          ;;
      esac

      val=$(${pkgs.brightnessctl}/bin/brightnessctl -d "$dev" -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -n1)
      if [ -n "$val" ]; then
        ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -h int:value:"$val" -t 1500 "Luz do Teclado: $val%"
      fi
    else
      # 2. Teclados externos (Logitech MX Keys / sem interface direta em /sys/class/leds)
      SOLAAR_CMD=""
      if command -v solaar >/dev/null 2>&1; then
        SOLAAR_CMD="solaar"
      elif [ -x "${pkgs.solaar}/bin/solaar" ]; then
        SOLAAR_CMD="${pkgs.solaar}/bin/solaar"
      fi

      if [ -n "$SOLAAR_CMD" ]; then
        case "$1" in
          up|toggle)
            "$SOLAAR_CMD" config "MX Keys" backlight true 2>/dev/null || \
            "$SOLAAR_CMD" config active backlight true 2>/dev/null || \
            "$SOLAAR_CMD" config 1 backlight true 2>/dev/null || true
            ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Aumentar / Ativada"
            ;;
          down)
            "$SOLAAR_CMD" config "MX Keys" backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config active backlight false 2>/dev/null || \
            "$SOLAAR_CMD" config 1 backlight false 2>/dev/null || true
            ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Diminuir / Desativada"
            ;;
        esac
      else
        case "$1" in
          up)   ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (F4 / MX Keys): Aumentar" ;;
          down) ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (F3 / MX Keys): Diminuir" ;;
          toggle) ${pkgs.dunst}/bin/dunstify -a "OSD" -u low -i "input-keyboard" -r 9993 -t 1500 "Luz do Teclado (MX Keys): Alternar" ;;
        esac
      fi
    fi
  '';

  # --- Dashboard Unificado: Quick Settings + Manual de Atalhos (Estilo Hyprland) ---
  quickSettings = pkgs.writeShellScript "quick-settings" ''
        show_manual() {
          KB_LIST="󰌌  ${modDisplayName} + Space / ${modDisplayName} + D     ➜  Lançador de Aplicativos (Rofi)
    󰌌  ${modDisplayName} + Enter / ${modDisplayName} + T     ➜  Abrir Terminal (Alacritty)
    󰌌  ${modDisplayName} + B                     ➜  Navegador Web Padrão
    󰌌  ${modDisplayName} + E / ${modDisplayName} + Shift + E ➜  Gerenciador de Arquivos (''${fmName})
    󰌌  ${modDisplayName} + , / ${modDisplayName} + C / Botão Dir. ➜ Painel Quick Settings / Preferências
    󰌌  ${modDisplayName} + / ou ${modDisplayName} + F1       ➜  Manual e Guia de Atalhos (Cheat-Sheet)
    󰌌  ${altDisplayName} + Tab / ${modDisplayName} + W         ➜  Alternador de Janelas Abertas
    󰌌  ${modDisplayName} + U                     ➜  Terminal Flutuante Rápido (Scratchpad)
    󰌌  ${modDisplayName} + Q / ${modDisplayName} + Shift + Q ➜  Fechar / Encerrar Janela
    󰌌  ${modDisplayName} + ${if mod == "alt" then "Super" else "Alt"} + Esc             ➜  Forçar Fechamento de Janela Travada
    󰌌  Alt + A                                 ➜  Alternar Tela Cheia (Fullscreen)
    󰌌  ${modDisplayName} + F                     ➜  Alternar Janela Flutuante (Floating/Tiling)
    󰌌  ${modDisplayName} + M                     ➜  Modo Monocle (Foco em Janela Única)
    󰌌  ${modDisplayName} + Y / ${modDisplayName} + Minus     ➜  Esconder / Minimizar Janela Ativa
    󰌌  ${modDisplayName} + Shift + Y / Shift+-  ➜  Restaurar Última Janela Escondida
    󰌌  ${modDisplayName} + Shift + M            ➜  Mostrar Desktop (Minimizar/Restaurar Todas)
    󰌌  ${modDisplayName} + {H,J,K,L} ou Setas    ➜  Navegar Foco Entre Janelas (Vim/Setas)
    󰌌  ${modDisplayName} + Shift + {H,J,K,L}     ➜  Mover / Trocar Posição da Janela
    󰌌  ${modDisplayName} + ${if mod == "alt" then "Super" else "Alt"} + {H,J,K,L}/Setas ➜  Redimensionar Tamanho da Janela
    󰌌  ${modDisplayName} + Botão Esquerdo        ➜  Mover Janela Flutuante com o Mouse
    󰌌  ${modDisplayName} + Botão Direito         ➜  Redimensionar Janela com o Mouse
    󰌌  ${modDisplayName} + 1..9, 0               ➜  Ir para Área de Trabalho (Workspace) 1 a 10
    󰌌  ${modDisplayName} + Shift + 1..9, 0       ➜  Enviar Janela para Workspace 1 a 10
    󰌌  ${modDisplayName} + Shift + 3 / Shift+Prt ➜  Captura de Tela Inteira (salva em ~/Pictures)
    󰌌  ${modDisplayName} + Shift + 4 / Print     ➜  Seleção de Área para Captura (Flameshot)
    󰌌  ${modDisplayName} + Shift + 5             ➜  Interface Gráfica de Capturas
    󰌌  ${modDisplayName} + Shift + R             ➜  Recarregar BSPWM e Polybar
    󰌌  ${modDisplayName} + ${if mod == "ctrl" then "Super" else "Ctrl"} + Q              ➜  Bloquear Sessão do Usuário
    󰌌  Teclas de Volume / Brilho     ➜  Controle com Feedback Visual OSD"

          CHOICE=$(echo "$KB_LIST" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰌌 Manual de Atalhos (Keybinds) " -theme-str 'window { width: 720px; height: 520px; } listview { columns: 1; lines: 12; }')

          case "$CHOICE" in
            *"Lançador de Aplicativos"*) ${pkgs.rofi}/bin/rofi -show drun ;;
            *"Abrir Terminal"*) ${pkgs.alacritty}/bin/alacritty & ;;
            *"Navegador Web Padrão"*) if [ -n "$BROWSER" ]; then "$BROWSER" & else ${pkgs.xdg-utils}/bin/xdg-open https:// 2>/dev/null || ${pkgs.firefox}/bin/firefox & fi ;;
            *"Gerenciador de Arquivos"*) ''${fmCmd} ~ & ;;
            *"Painel Quick Settings"*) show_control_center ;;
            *"Alternador de Janelas"*) ${pkgs.rofi}/bin/rofi -show window ;;
            *"Terminal Flutuante"*) ${pkgs.tdrop}/bin/tdrop -am -w 80% -h 40% -x 10% -y 10% ${pkgs.alacritty}/bin/alacritty ;;
            *"Fechar / Encerrar Janela"*) bspc node -c ;;
            *"Tela Cheia"*) bspc node -t '~fullscreen' ;;
            *"Janela Flutuante"*) bspc node -t '~floating' ;;
            *"Esconder / Minimizar Janela"*) bspc node -g hidden=on ;;
            *"Restaurar Última Janela"*) bspc node any.hidden.local -g hidden=off -f ;;
            *"Captura de Tela Inteira"*) ${pkgs.flameshot}/bin/flameshot full -p ~/Pictures/ ;;
            *"Seleção de Área"*) ${pkgs.flameshot}/bin/flameshot gui ;;
            *"Recarregar BSPWM"*) bspc wm -r ;;
            *"Bloquear Sessão"*) loginctl lock-session ;;
          esac
        }

        show_control_center() {
          OPT_RES="󰍹  Resolução da Tela (Display Resolution)"
          OPT_SOUND="󰕾  Controle de Áudio & Volume (Pavucontrol)"
          OPT_NET="󰖩  Wi-Fi & Conexões (NetworkManager)"
          OPT_THEME="󰔎  Aparência, Ícones & Temas (LXAppearance)"
          OPT_WALL="󰸉  Papel de Parede (Wallpaper)"
          OPT_BROWSER="󰈹  Navegador Web (Firefox / Padrão)"
          OPT_FILES="󰉋  Gerenciador de Arquivos (''${fmName})"
          OPT_TERM="󰞷  Abrir Terminal (Alacritty)"
          OPT_KEYS="󰌌  Manual & Guia de Atalhos (Keybinds)"
          OPT_RELOAD="󰑐  Recarregar BSPWM & Polybar"
          OPT_POWER="󰐥  Menu de Energia & Bloqueio de Sessão"

          CHOICE=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s" \
            "$OPT_RES" \
            "$OPT_SOUND" \
            "$OPT_NET" \
            "$OPT_THEME" \
            "$OPT_WALL" \
            "$OPT_BROWSER" \
            "$OPT_FILES" \
            "$OPT_TERM" \
            "$OPT_KEYS" \
            "$OPT_RELOAD" \
            "$OPT_POWER" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󱗼 Quick Settings ")

          case "$CHOICE" in
            "$OPT_RES")
              R_1080="1920x1080 (Full HD 1080p)"
              R_2K="2560x1440 (Quad HD 2K)"
              R_900="1600x900 (HD+)"
              R_768="1366x768 (HD)"
              R_CUSTOM="⚙ Painel Avançado de Telas (ARandR)"

              RES=$(printf "%s\n%s\n%s\n%s\n%s" "$R_1080" "$R_2K" "$R_900" "$R_768" "$R_CUSTOM" | ${pkgs.rofi}/bin/rofi -dmenu -i -p " 󰍹 Selecionar Resolução ")
              case "$RES" in
                "$R_1080") ${pkgs.xorg.xrandr}/bin/xrandr -s 1920x1080 ;;
                "$R_2K")   ${pkgs.xorg.xrandr}/bin/xrandr -s 2560x1440 ;;
                "$R_900")  ${pkgs.xorg.xrandr}/bin/xrandr -s 1600x900 ;;
                "$R_768")  ${pkgs.xorg.xrandr}/bin/xrandr -s 1366x768 ;;
                "$R_CUSTOM") ${pkgs.arandr}/bin/arandr || ${pkgs.xorg.xrandr}/bin/xrandr ;;
              esac
              ;;
            "$OPT_SOUND") ${pkgs.pavucontrol}/bin/pavucontrol & ;;
            "$OPT_NET") ${pkgs.networkmanagerapplet}/bin/nm-connection-editor & ;;
            "$OPT_THEME") ${pkgs.lxappearance}/bin/lxappearance & ;;
            "$OPT_WALL") ${pkgs.nitrogen}/bin/nitrogen || ${pkgs.feh}/bin/feh & ;;
            "$OPT_BROWSER")
              if [ -n "$BROWSER" ]; then "$BROWSER" & else ${pkgs.xdg-utils}/bin/xdg-open https:// 2>/dev/null || ${pkgs.firefox}/bin/firefox & fi
              ;;
            "$OPT_FILES") ''${fmCmd} ~ & ;;
            "$OPT_TERM") ${pkgs.alacritty}/bin/alacritty & ;;
            "$OPT_KEYS") show_manual ;;
            "$OPT_RELOAD")
              bspc wm -r
              ${pkgs.dunst}/bin/dunstify -a "Sistema" -u low -i "view-refresh" -t 2000 "BSPWM e Polybar recarregados com sucesso!"
              ;;
            "$OPT_POWER")
              ${pkgs.rofi}/bin/rofi -show power-menu -modi "power-menu:${pkgs.rofi-power-menu}/bin/rofi-power-menu" || loginctl lock-session
              ;;
          esac
        }

        case "$1" in
          --manual) show_manual ;;
          *) show_control_center ;;
        esac
  '';
in
{
  options.desktop.bspwm.sxhkd = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable sxhkd keybindings for bspwm";
    };

    modifierKey = mkOption {
      type = lib.types.str;
      default = config.desktop.bspwm.modifierKey or (config.desktop.modifierKey or "Super");
      description = "Tecla modificadora principal do SXHKD (ex: 'super', 'alt', 'ctrl').";
    };

    keybindings = mkOption {
      type = attrs;
      default = { };
      description = "sxhkd keybindings";
    };
  };

  config = mkIf cfg.enable {
    # Recarregar automaticamente o sxhkd e polybar ao rodar switch-home (sem reiniciar o bspwm para não derrubar a sessão X11)
    home.activation.reloadSxhkd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -USR1 -x sxhkd 2>/dev/null || true
      $DRY_RUN_CMD ${pkgs.polybar}/bin/polybar-msg cmd restart 2>/dev/null || true
    '';

    services.sxhkd = {
      enable = true;
      package = pkgs.sxhkd;
      keybindings = cfg.keybindings // {
        # --- Clique no Desktop / Control Center (Estilo Hyprland / SwayNC) ---
        # Botão Direito no Desktop (Root Window sem janela)
        "~button3" =
          "if [ -z \"$(bspc query -N -n pointed.window 2>/dev/null)\" ]; then ${quickSettings}; fi";
        "${mod} + button3" = "${quickSettings}";
        "${mod} + comma" = "${quickSettings}"; # Cmd + , (Atalho universal de Preferências)
        "${mod} + p" = "${quickSettings}";
        "${mod} + c" = "${quickSettings}"; # Control Center
        "${mod} + slash" = "${quickSettings} --manual"; # Cmd + / (Manual & Cheat-Sheet de Atalhos)
        "${mod} + F1" = "${quickSettings} --manual"; # F1 (Ajuda do Sistema)

        # --- Aplicativos & Launchers (macOS Style) ---
        # Spotlight (Cmd + Space) e Rofi Drun
        "${mod} + space" = "${pkgs.rofi}/bin/rofi -show drun";
        "${mod} + d" = "${pkgs.rofi}/bin/rofi -show drun";
        "${mod} + shift + d" = "${pkgs.rofi}/bin/rofi -show run";

        # Navegador Web Padrão (Cmd + B)
        "${mod} + b" =
          "if [ -n \"$BROWSER\" ]; then \"$BROWSER\" & else ${pkgs.xdg-utils}/bin/xdg-open https:// 2>/dev/null || ${pkgs.firefox}/bin/firefox & fi";

        # Terminal (Cmd + Return, Cmd + T)
        "${mod} + Return" = "${pkgs.alacritty}/bin/alacritty";
        "${mod} + KP_Enter" = "${pkgs.alacritty}/bin/alacritty";
        "${mod} + t" = "${pkgs.alacritty}/bin/alacritty";

        # Finder / Gerenciador de Arquivos (Cmd + Shift + F, Cmd + E)
        "${mod} + e" = fmCmd;
        "${mod} + shift + e" = fmCmd;

        # Alternador de Janelas (Cmd + Tab / Cmd + W)
        "${altMod} + Tab" = "${pkgs.rofi}/bin/rofi -show window";
        "${mod} + w" = "${pkgs.rofi}/bin/rofi -show window";

        # Terminal Scratchpad (Cmd + U)
        "${mod} + u" =
          "${pkgs.tdrop}/bin/tdrop -am -w 80% -h 40% -x 10% -y 10% ${pkgs.alacritty}/bin/alacritty";

        # --- Janelas (macOS Style: Cmd + Q / Cmd + Opt + Esc) ---
        "${mod} + q" = "bspc node -c";
        "${mod} + ${altMod} + Escape" = "bspc node -k";
        "${mod} + shift + q" = "bspc node -k";

        # --- Estados de Janela (Alternar Flutuante / Tela Cheia / Monocle) ---
        "${mod} + f" = "bspc node -t '~floating'";
        "${mod} + s" = "bspc node -t '~floating'";
        "alt + a" = "bspc node -t '~fullscreen'";
        "${mod} + m" = "bspc desktop -l next";

        # --- Minimizar / Esconder Janelas (Desktop Environment Style) ---
        # Esconder/Minimizar a janela ativa (Cmd + Y ou Cmd + -)
        "${mod} + y" = "bspc node -g hidden=on";
        "${mod} + minus" = "bspc node -g hidden=on";

        # Restaurar/Desocultar a última janela escondida (Cmd + Shift + Y ou Cmd + Shift + -)
        "${mod} + shift + y" = "bspc node any.hidden.local -g hidden=off -f";
        "${mod} + shift + minus" = "bspc node any.hidden.local -g hidden=off -f";

        # Alternar Mostrar Desktop (Minimizar todas / Restaurar todas no workspace ativo)
        "${mod} + shift + m" =
          "if [ $(bspc query -N -d focused -n .window.!hidden | wc -l) -gt 0 ]; then for n in $(bspc query -N -d focused -n .window.!hidden); do bspc node $n -g hidden=on; done; else for n in $(bspc query -N -d focused -n .window.hidden); do bspc node $n -g hidden=off; done; fi";

        # --- Screenshots (macOS Style: Cmd + Shift + 3 / 4 / 5) ---
        # Cmd + Shift + 3: Captura de tela inteira salva em ~/Pictures
        "${mod} + shift + 3" = "${pkgs.flameshot}/bin/flameshot full -p ~/Pictures/";
        # Cmd + Shift + 4: Seleção interativa de área
        "${mod} + shift + 4" = "${pkgs.flameshot}/bin/flameshot gui";
        # Cmd + Shift + 5: Ferramenta GUI de captura
        "${mod} + shift + 5" = "${pkgs.flameshot}/bin/flameshot gui";
        # Atalhos padrão PrintScreen (fallback)
        "Print" = "${pkgs.flameshot}/bin/flameshot gui";
        "shift + Print" = "${pkgs.flameshot}/bin/flameshot full -p ~/Pictures/";

        # --- Bloqueio & Sessão (macOS Style: Cmd + Ctrl + Q) ---
        "${mod} + ${ctrlMod} + q" = "loginctl lock-session";
        "${mod} + shift + x" = "loginctl lock-session";

        # --- Foco e Movimento em Janelas (Vim + Setas) ---
        "${mod} + {h,j,k,l}" = "bspc node -f {west,south,north,east}";
        "${mod} + {Left,Down,Up,Right}" = "bspc node -f {west,south,north,east}";
        "${mod} + shift + {h,j,k,l}" = "bspc node -s {west,south,north,east}";
        "${mod} + shift + {Left,Down,Up,Right}" = "bspc node -s {west,south,north,east}";

        # --- Navegação e Envio de Janelas Entre Monitores ---
        "${mod} + bracketleft" = "bspc monitor -f prev";
        "${mod} + bracketright" = "bspc monitor -f next";
        "${mod} + shift + bracketleft" = "bspc node -m prev --follow";
        "${mod} + shift + bracketright" = "bspc node -m next --follow";

        # --- Áreas de Trabalho (Workspaces 1-10, onde 0 = 10) ---
        "${mod} + {1-9,0}" = "bspc desktop -f '{1-9,0}'";
        "${mod} + shift + {1-9,0}" = "bspc node -d '{1-9,0}'";

        # --- Redimensionar Janelas (Super + Alt + Setas/Vim) ---
        "${mod} + ${altMod} + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
        "${mod} + ${altMod} + {Left,Down,Up,Right}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";

        # --- Reiniciar / Recarregar BSPWM e SXHKD ---
        "${mod} + shift + r" = "bspc wm -r";
        "${mod} + Escape" = "pkill -USR1 -x sxhkd";

        # --- Controles de Mídia e Áudio com Dunst OSD ---
        "XF86AudioRaiseVolume" = "${volumeOsd} up";
        "XF86AudioLowerVolume" = "${volumeOsd} down";
        "XF86AudioMute" = "${volumeOsd} mute";
        "XF86AudioPlay" = "${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "${pkgs.playerctl}/bin/playerctl previous";

        # --- Controle de Brilho da Tela (MacBook F1 / F2) ---
        "XF86MonBrightnessUp" = "${brightnessOsd} up";
        "XF86MonBrightnessDown" = "${brightnessOsd} down";

        # --- Controle de Iluminação do Teclado (MacBook F5/F6 e Logitech MX Keys F3/F4) ---
        "XF86KbdBrightnessUp" = "${kbdBrightnessOsd} up";
        "XF86KbdBrightnessDown" = "${kbdBrightnessOsd} down";
        "XF86KbdLightOnOff" = "${kbdBrightnessOsd} toggle";

        # MacBook (F5 / F6)
        "${mod} + F6" = "${kbdBrightnessOsd} up";
        "${mod} + F5" = "${kbdBrightnessOsd} down";
        "${mod} + shift + F5" = "${kbdBrightnessOsd} toggle";

        # Logitech MX Keys / Teclados com F3 (down) e F4 (up)
        "${mod} + F4" = "${kbdBrightnessOsd} up";
        "${mod} + F3" = "${kbdBrightnessOsd} down";
        "${mod} + shift + F4" = "${kbdBrightnessOsd} toggle";
        "${mod} + shift + F3" = "${kbdBrightnessOsd} toggle";
      } // lib.optionalAttrs (mod != "super") {
        # Atalhos com Super garantidos mesmo quando mod != "super"
        "super + F4" = "${kbdBrightnessOsd} up";
        "super + F3" = "${kbdBrightnessOsd} down";
        "super + shift + F4" = "${kbdBrightnessOsd} toggle";
        "super + shift + F3" = "${kbdBrightnessOsd} toggle";
        "super + F6" = "${kbdBrightnessOsd} up";
        "super + F5" = "${kbdBrightnessOsd} down";
        "super + shift + F5" = "${kbdBrightnessOsd} toggle";
      };
    };
  };
}
