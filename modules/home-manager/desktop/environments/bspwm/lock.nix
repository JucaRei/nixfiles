{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.bspwm.lock;
  bspwmCfg = config.desktop.bspwm;

  # Script principal de bloqueio de tela com visual Catppuccin Mocha minimalista e elegante
  lockScript = pkgs.writeShellScriptBin "bspwm-lock" ''
        export PATH="${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.procps
            pkgs.gnugrep
            pkgs.xset
            pkgs.libnotify
          ]
        }:$PATH"

        # Evita lançar múltiplas instâncias concorrentes caso a tela já esteja travada
        if pgrep -u "$UID" -x i3lock >/dev/null 2>&1 || pgrep -u "$UID" -x i3lock-color >/dev/null 2>&1; then
          exit 0
        fi

        # Validação de segurança PAM para evitar prender o usuário para fora sem conseguir destravar a sessão
        if [ ! -f /etc/pam.d/i3lock ] || [ ! -x /run/wrappers/bin/unix_chkpwd ]; then
          ERR="[bspwm-lock] ERRO: Pré-requisitos de autenticação PAM ausentes no host!\n"
          [ ! -f /etc/pam.d/i3lock ] && ERR="''${ERR}  - Falta o arquivo de serviço: /etc/pam.d/i3lock\n"
          [ ! -x /run/wrappers/bin/unix_chkpwd ] && ERR="''${ERR}  - Falta o helper setuid: /run/wrappers/bin/unix_chkpwd\n"
          ERR="''${ERR}\nExecute os comandos de configuração do PAM e dos wrappers descritos no WIKI.md para poder desbloquear a tela com sua senha."
          echo -e "$ERR" >&2
          notify-send -u critical -i dialog-error "BSPWM Lock" "Falha PAM: configure /etc/pam.d/i3lock e /run/wrappers/bin/unix_chkpwd para poder desbloquear com sua senha." 2>/dev/null || true
          exit 1
        fi

        # Configurações padrão compiladas declarativamente pelo Nix
        BLUR="${toString cfg.blur}"
        WALLPAPER="${if cfg.wallpaper != null then toString cfg.wallpaper else ""}"
        FONT="${cfg.font}"
        TIME_FONT="${cfg.timeFont}"
        DATE_FONT="${cfg.dateFont}"
        TIME_FORMAT="${cfg.timeFormat}"
        DATE_FORMAT="${cfg.dateFormat}"
        TIME_SIZE="${toString cfg.timeSize}"
        DATE_SIZE="${toString cfg.dateSize}"
        INDICATOR_RADIUS="${toString cfg.radius}"
        RING_WIDTH="${toString cfg.ringWidth}"

        COLOR_BASE="${cfg.colors.base}"
        COLOR_MANTLE="${cfg.colors.mantle}"
        COLOR_MAUVE="${cfg.colors.mauve}"
        COLOR_BLUE="${cfg.colors.blue}"
        COLOR_GREEN="${cfg.colors.green}"
        COLOR_RED="${cfg.colors.red}"
        COLOR_PEACH="${cfg.colors.peach}"
        COLOR_TEXT="${cfg.colors.text}"
        COLOR_SUBTEXT="${cfg.colors.subtext}"

        EXTRA_ARGS="${lib.concatStringsSep " " cfg.extraArgs}"
        NOFORK_FLAG=""

        # Carrega arquivo de configuração local do usuário se existir (permite customização runtime sem rebuild)
        USER_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/bspwm/lock.conf"
        if [ -f "$USER_CONFIG" ]; then
          # shellcheck source=/dev/null
          . "$USER_CONFIG"
        fi

        # Parsing de argumentos de linha de comando
        while [ $# -gt 0 ]; do
          case "$1" in
            -h|--help)
              cat << 'EOF'
    Uso: bspwm-lock [opções]

    Bloqueador de tela minimalista, elegante e customizável para BSPWM (i3lock-color).

    Opções:
      -b, --blur <N>        Raio de desfoque gaussiano da tela atual (padrão: 8, 0 para desligar)
      --no-blur             Desativa o desfoque (usa cor sólida ou wallpaper)
      -i, --image <caminho> Usa a imagem informada como fundo de bloqueio
      -n, --nofork          Mantém em primeiro plano (requerido pelo xss-lock e suspend)
      -h, --help            Exibe esta mensagem de ajuda

    Arquivo de personalização local:
      ~/.config/bspwm/lock.conf
    EOF
              exit 0
              ;;
            -b|--blur)
              BLUR="$2"
              shift 2
              ;;
            --no-blur)
              BLUR="0"
              shift
              ;;
            -i|--image|--wallpaper)
              WALLPAPER="$2"
              shift 2
              ;;
            -n|--nofork)
              NOFORK_FLAG="--nofork"
              shift
              ;;
            *)
              break
              ;;
          esac
        done

        # Seleção do modo de plano de fundo
        BG_OPTS=()
        if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
          BG_OPTS+=("-i" "$WALLPAPER")
        elif [ "$BLUR" -gt 0 ] 2>/dev/null; then
          BG_OPTS+=("--blur=$BLUR")
        else
          BG_OPTS+=("-c" "$COLOR_BASE")
        fi

        # Invocação do i3lock-color com estética moderna Catppuccin Mocha:
        # - Desfoque suave da área de trabalho
        # - Relógio e data centralizados acima do anel
        # - Anel minimalista, fino e translúcido
        # - Destaques suaves nas teclas (verde) e backspace (vermelho)
        # - Avisos de Caps Lock e erros em tons pastel coerentes
        # - Passagem de teclas de volume e brilho mesmo com tela travada
        exec ${cfg.package}/bin/i3lock-color \
          "''${BG_OPTS[@]}" \
          --clock \
          --indicator \
          --ind-pos="x+(w/2):y+(h/2)+55" \
          --time-pos="ix:iy-115" \
          --date-pos="ix:iy-70" \
          --time-str="$TIME_FORMAT" \
          --time-size="$TIME_SIZE" \
          --time-color="''${COLOR_TEXT}ff" \
          --time-font="$TIME_FONT" \
          --date-str="$DATE_FORMAT" \
          --date-size="$DATE_SIZE" \
          --date-color="''${COLOR_SUBTEXT}ff" \
          --date-font="$DATE_FONT" \
          --radius="$INDICATOR_RADIUS" \
          --ring-width="$RING_WIDTH" \
          --inside-color="''${COLOR_BASE}88" \
          --ring-color="''${COLOR_MAUVE}ee" \
          --line-color="00000000" \
          --separator-color="00000000" \
          --keyhl-color="''${COLOR_GREEN}ff" \
          --bshl-color="''${COLOR_RED}ff" \
          --insidever-color="''${COLOR_MANTLE}cc" \
          --ringver-color="''${COLOR_BLUE}ff" \
          --verif-text="Verificando..." \
          --verif-color="''${COLOR_TEXT}ff" \
          --verif-font="$FONT" \
          --verif-size=16 \
          --insidewrong-color="''${COLOR_MANTLE}cc" \
          --ringwrong-color="''${COLOR_RED}ff" \
          --wrong-text="Senha incorreta" \
          --wrong-color="''${COLOR_RED}ff" \
          --wrong-font="$FONT" \
          --wrong-size=16 \
          --modif-color="''${COLOR_PEACH}ff" \
          --keylayout 1 \
          --layout-font="$FONT" \
          --layout-size=14 \
          --layout-color="''${COLOR_SUBTEXT}ff" \
          --ignore-empty-password \
          --show-failed-attempts \
          --pass-media-keys \
          --pass-screen-keys \
          --pass-volume-keys \
          $NOFORK_FLAG \
          $EXTRA_ARGS \
          "$@"
  '';
in
{
  options.desktop.bspwm.lock = {
    enable = lib.my.mkBool bspwmCfg.enable "Habilitar bloqueador de tela moderno, minimalista e customizável para BSPWM (i3lock-color + xss-lock)";

    lockScript = lib.my.mkPkg lockScript "Pacote derivado com o script executável bspwm-lock";

    timeout = lib.my.mkInt 600 "Tempo de inatividade em segundos para bloqueio automático de tela via X11 screensaver / xss-lock (0 para desativar, padrão: 600 = 10 min).";

    dpmsTimeout = lib.my.mkInt 900 "Tempo de inatividade em segundos para desligamento da tela via DPMS (0 para desativar, padrão: 900 = 15 min).";

    package = lib.my.mkPkg pkgs.i3lock-color "Pacote do i3lock-color a ser utilizado";

    blur = lib.my.mkInt 8 "Raio do desfoque gaussiano da tela atual (0 para desativar blur)";

    wallpaper =
      lib.my.mkOpt (lib.types.nullOr (lib.types.either lib.types.path lib.types.str)) null
        "Papel de parede fixo opcional para a tela de bloqueio (se nulo, usa o screenshot com blur)";

    font = lib.my.mkStr "Inter" "Família de fonte padrão para a interface da lockscreen";

    timeFont = lib.my.mkStr "Inter Bold" "Família de fonte para o relógio da lockscreen";

    dateFont = lib.my.mkStr "Inter Medium" "Família de fonte para a data da lockscreen";

    timeFormat = lib.my.mkStr "%H:%M:%S" "Formato de exibição do horário (strftime)";

    dateFormat = lib.my.mkStr "%A, %d de %B de %Y" "Formato de exibição da data (strftime)";

    timeSize = lib.my.mkInt 64 "Tamanho da tipografia do relógio";

    dateSize = lib.my.mkInt 16 "Tamanho da tipografia da data";

    radius = lib.my.mkInt 110 "Raio do anel circular de desbloqueio em pixels";

    ringWidth = lib.my.mkInt 7 "Espessura da linha do anel de desbloqueio em pixels";

    colors = {
      base = lib.my.mkStr "1e1e2e" "Cor de fundo / interior padrão (Catppuccin Base, hex sem #)";
      mantle = lib.my.mkStr "181825" "Cor de verificação / interior secundário (Catppuccin Mantle)";
      mauve = lib.my.mkStr "cba6f7" "Cor de destaque principal / anel padrão (Catppuccin Mauve)";
      blue = lib.my.mkStr "89b4fa" "Cor do anel em estado de verificação (Catppuccin Blue)";
      green = lib.my.mkStr "a6e3a1" "Cor dos destaques de teclas no anel (Catppuccin Green)";
      red = lib.my.mkStr "f38ba8" "Cor de erro ou backspace (Catppuccin Red)";
      peach = lib.my.mkStr "fab387" "Cor de aviso do Caps Lock (Catppuccin Peach)";
      text = lib.my.mkStr "cdd6f4" "Cor do texto do relógio e verificação (Catppuccin Text)";
      subtext = lib.my.mkStr "a6adc8" "Cor do texto secundário e data (Catppuccin Subtext0)";
    };

    extraArgs =
      lib.my.mkListOf lib.types.str [ ]
        "Argumentos adicionais repassados diretamente para o binário i3lock-color";
  };

  config = mkIf cfg.enable {
    home = {
      # Pacotes instalados no ambiente do usuário
      packages = [
        cfg.package
        pkgs.xss-lock
        lockScript
        (pkgs.writeShellScriptBin "lock-screen" ''exec ${lockScript}/bin/bspwm-lock "$@"'')
        (pkgs.writeShellScriptBin "lock" ''exec ${lockScript}/bin/bspwm-lock "$@"'')
      ];

      # Inicializa ~/.config/bspwm/lock.conf como arquivo gravável real se ainda não existir
      activation.setupBspwmLockConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        LOCK_CONF="$HOME/.config/bspwm/lock.conf"
        LOCK_DEFAULT="$HOME/.config/bspwm/lock.conf.default"
        if [ -f "$LOCK_DEFAULT" ] && [ ! -f "$LOCK_CONF" ]; then
          $DRY_RUN_CMD mkdir -p "$HOME/.config/bspwm"
          $DRY_RUN_CMD cp -f "$LOCK_DEFAULT" "$LOCK_CONF"
          $DRY_RUN_CMD chmod 644 "$LOCK_CONF" 2>/dev/null || true
        fi
      '';

      # Recarrega o serviço xss-lock automaticamente ao rodar switch
      activation.reloadXssLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if systemctl --user is-active --quiet graphical-session.target 2>/dev/null || pgrep -f bspwm >/dev/null 2>&1; then
          systemctl --user daemon-reload 2>/dev/null || true
          systemctl --user restart xss-lock.service 2>/dev/null || true
        fi
      '';
    };

    # Template de configuração padrão em ~/.config/bspwm/lock.conf.default
    xdg.configFile."bspwm/lock.conf.default".text = ''
      # ==============================================================================
      #  BSPWM LOCK SCREEN CONFIGURATION (i3lock-color / Catppuccin Mocha)
      #  Arquivo lido dinamicamente pelo script 'bspwm-lock' (ou 'lock-screen').
      #  Altere qualquer valor aqui para customizar seu bloqueador instantaneamente!
      # ==============================================================================

      # Raio de desfoque gaussiano da tela atual (padrão: 8, 0 para desativar)
      BLUR=${toString cfg.blur}

      # Papel de parede alternativo (caminho absoluto para PNG/JPG). Se vazio, usa blur da tela atual.
      WALLPAPER="${if cfg.wallpaper != null then toString cfg.wallpaper else ""}"

      # Tipografia (Fontconfig / Pango)
      FONT="${cfg.font}"
      TIME_FONT="${cfg.timeFont}"
      DATE_FONT="${cfg.dateFont}"
      TIME_FORMAT="${cfg.timeFormat}"
      DATE_FORMAT="${cfg.dateFormat}"
      TIME_SIZE=${toString cfg.timeSize}
      DATE_SIZE=${toString cfg.dateSize}

      # Geometria do anel de desbloqueio (em pixels)
      INDICATOR_RADIUS=${toString cfg.radius}
      RING_WIDTH=${toString cfg.ringWidth}

      # Paleta de Cores Catppuccin Mocha (formato RRGGBB sem '#')
      COLOR_BASE="${cfg.colors.base}"
      COLOR_MANTLE="${cfg.colors.mantle}"
      COLOR_MAUVE="${cfg.colors.mauve}"
      COLOR_BLUE="${cfg.colors.blue}"
      COLOR_GREEN="${cfg.colors.green}"
      COLOR_RED="${cfg.colors.red}"
      COLOR_PEACH="${cfg.colors.peach}"
      COLOR_TEXT="${cfg.colors.text}"
      COLOR_SUBTEXT="${cfg.colors.subtext}"

      # Argumentos adicionais opcionais para o i3lock-color (ex: "--greyscale", etc.)
      EXTRA_ARGS="${lib.concatStringsSep " " cfg.extraArgs}"
    '';

    # Serviço systemd do usuário gerenciando o daemon xss-lock
    systemd.user.services.xss-lock = {
      Unit = {
        Description = "XSS Lock Screen Daemon (i3lock-color)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStartPre = pkgs.writeShellScript "xss-lock-pre" ''
          if [ "${toString cfg.timeout}" -gt 0 ]; then
            ${pkgs.xset}/bin/xset s "${toString cfg.timeout}" "${toString cfg.timeout}" 2>/dev/null || true
            ${pkgs.xset}/bin/xset +dpms dpms "${toString cfg.timeout}" "${toString cfg.dpmsTimeout}" "${
              toString (cfg.dpmsTimeout + 300)
            }" 2>/dev/null || true
          fi
        '';
        ExecStart = "${pkgs.xss-lock}/bin/xss-lock --transfer-sleep-lock -- ${lockScript}/bin/bspwm-lock --nofork";
        Restart = "always";
        RestartSec = 2;
        PassEnvironment = [
          "DISPLAY"
          "XAUTHORITY"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
