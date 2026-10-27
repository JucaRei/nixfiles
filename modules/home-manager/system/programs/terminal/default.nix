{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    optionalString
    types
    ;

  cfg = config.system.programs.terminal;
  isUrxvt = (cfg.name or "") == "urxvt" || (cfg.name or "") == "rxvt";
  alacrittyPkg =
    if config.programs.alacritty.enable then
      config.programs.alacritty.package
    else
      nixGLWrapper pkgs.alacritty;
  kittyPkg = nixGLWrapper pkgs.kitty;
  footPkg = nixGLWrapper pkgs.foot;
  weztermPkg = nixGLWrapper pkgs.wezterm;

  # Determina o nome canônico amigável do terminal ativo
  activeName =
    if cfg.command != null then
      "Terminal (${cfg.command})"
    else if isUrxvt then
      "URxvt"
    else if cfg.name == "alacritty" then
      "Alacritty"
    else if cfg.name == "kitty" then
      "Kitty"
    else if cfg.name == "foot" then
      "Foot"
    else if cfg.name == "wezterm" then
      "Wezterm"
    else if cfg.name == "xfce4-terminal" then
      "Xfce4 Terminal"
    else if cfg.name != null && cfg.name != "" then
      cfg.name
    else
      "Terminal";

  # Determina o comando exato para invocar o terminal ativo
  computedActiveCommand =
    if cfg.command != null then
      cfg.command
    else if isUrxvt then
      "${config.home.homeDirectory}/.local/bin/term"
    else if cfg.name == "alacritty" then
      "${alacrittyPkg}/bin/alacritty --working-directory $HOME"
    else if cfg.name == "kitty" then
      "${kittyPkg}/bin/kitty --directory $HOME"
    else if cfg.name == "foot" then
      "${footPkg}/bin/foot"
    else if cfg.name == "wezterm" then
      "${weztermPkg}/bin/wezterm start --cwd $HOME"
    else if cfg.name == "xfce4-terminal" then
      "${pkgs.xfce4-terminal}/bin/xfce4-terminal --working-directory=$HOME"
    else if cfg.name != null && cfg.name != "" then
      cfg.name
    else
      "terminal";

  # Comando para iniciar em um diretório de trabalho específico (usado por file managers / thunar)
  computedWorkingDirCommand =
    if isUrxvt then
      "${config.home.homeDirectory}/.local/bin/term -cd"
    else if cfg.name == "alacritty" then
      "${alacrittyPkg}/bin/alacritty --working-directory"
    else if cfg.name == "kitty" then
      "${kittyPkg}/bin/kitty --directory"
    else if cfg.name == "foot" then
      "${footPkg}/bin/foot -D"
    else if cfg.name == "wezterm" then
      "${weztermPkg}/bin/wezterm start --cwd"
    else if cfg.name == "xfce4-terminal" then
      "${pkgs.xfce4-terminal}/bin/xfce4-terminal --working-directory="
    else
      "terminal --working-directory";

  # Comando adaptado para o modo Scratchpad / Floating com classe ou título dedicado
  computedScratchpadCommand =
    if isUrxvt then
      "${computedActiveCommand} -name \"$SCRATCHPAD_NAME\""
    else if cfg.name == "alacritty" then
      "${alacrittyPkg}/bin/alacritty --class \"$SCRATCHPAD_NAME,$SCRATCHPAD_NAME\" --working-directory \"$HOME\""
    else if cfg.name == "kitty" then
      "${kittyPkg}/bin/kitty --class \"$SCRATCHPAD_NAME\" --directory \"$HOME\""
    else if cfg.name == "foot" then
      "${footPkg}/bin/foot --app-id \"$SCRATCHPAD_NAME\""
    else if cfg.name == "wezterm" then
      "${weztermPkg}/bin/wezterm start --class \"$SCRATCHPAD_NAME\" --cwd \"$HOME\""
    else
      "${computedActiveCommand}";

  # Despachante agnóstico universal: binário 'terminal' acessível globalmente no PATH
  # Executa o terminal configurado ou efetua fallback inteligente caso o binário não seja encontrado
  terminalDispatcher = pkgs.writeShellScriptBin "terminal" ''
    #!/bin/sh
    # Agnostic Terminal Dispatcher
    # Suporta:
    #   terminal                    -> Abre o terminal padrão
    #   terminal <comando> [args]   -> Executa comando dentro do terminal
    #   terminal --working-directory <dir> / terminal -d <dir> -> Abre no diretório especificado

    TARGET_DIR=""
    RUN_CMD=""

    while [ $# -gt 0 ]; do
      case "$1" in
        --working-directory|-d|--dir)
          TARGET_DIR="$2"
          shift 2
          ;;
        -e|--execute)
          shift
          RUN_CMD="$*"
          break
          ;;
        *)
          if [ -d "$1" ] && [ -z "$TARGET_DIR" ]; then
            TARGET_DIR="$1"
            shift
          else
            RUN_CMD="$*"
            break
          fi
          ;;
      esac
    done

    [ -n "$TARGET_DIR" ] && cd "$TARGET_DIR" 2>/dev/null || true

    # 1. Se houver comando configurado explicitamente no Nix
    ${optionalString (cfg.command != null) ''
      if [ -n "$RUN_CMD" ]; then
        exec ${cfg.command} -e $RUN_CMD
      else
        exec ${cfg.command}
      fi
    ''}

    # 2. Se for URxvt / RXVT
    ${optionalString isUrxvt ''
      TERM_BIN="${config.home.homeDirectory}/.local/bin/term"
      if [ -x "$TERM_BIN" ]; then
        if [ -n "$RUN_CMD" ]; then
          exec "$TERM_BIN" -e $RUN_CMD
        else
          exec "$TERM_BIN"
        fi
      fi
    ''}

    # 3. Se for Alacritty
    ${optionalString (cfg.name == "alacritty") ''
      if [ -n "$RUN_CMD" ]; then
        exec ${alacrittyPkg}/bin/alacritty -e $RUN_CMD
      else
        exec ${alacrittyPkg}/bin/alacritty --working-directory "''${TARGET_DIR:-$HOME}"
      fi
    ''}

    # 4. Se for Kitty
    ${optionalString (cfg.name == "kitty") ''
      if [ -n "$RUN_CMD" ]; then
        exec ${kittyPkg}/bin/kitty $RUN_CMD
      else
        exec ${kittyPkg}/bin/kitty --directory "''${TARGET_DIR:-$HOME}"
      fi
    ''}

    # 5. Se for Foot
    ${optionalString (cfg.name == "foot") ''
      if [ -n "$RUN_CMD" ]; then
        exec ${footPkg}/bin/foot $RUN_CMD
      else
        exec ${footPkg}/bin/foot -D "''${TARGET_DIR:-$HOME}"
      fi
    ''}

    # 6. Se for Wezterm
    ${optionalString (cfg.name == "wezterm") ''
      if [ -n "$RUN_CMD" ]; then
        exec ${weztermPkg}/bin/wezterm start -- $RUN_CMD
      else
        exec ${weztermPkg}/bin/wezterm start --cwd "''${TARGET_DIR:-$HOME}"
      fi
    ''}

    # 7. Fallback dinâmico: busca no PATH
    for t in "$TERMINAL" urxvtc urxvt alacritty kitty foot wezterm xfce4-terminal x-terminal-emulator xterm; do
      if [ -n "$t" ] && command -v "$t" >/dev/null 2>&1; then
        if [ -n "$RUN_CMD" ]; then
          exec "$t" -e $RUN_CMD 2>/dev/null || exec "$t" $RUN_CMD
        else
          exec "$t"
        fi
      fi
    done

    echo "Erro: Nenhum emulador de terminal encontrado no sistema." >&2
    exit 1
  '';
in
{
  imports = [
    ./alacritty
    ./urxvt
    # ./kitty
    # ./foot
    # ./wezterm
    # ./xfce4-terminal
  ];

  options = {
    system.programs.terminal = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable terminal emulator configuration.";
      };

      name = mkOption {
        type = types.nullOr types.str;
        default = "alacritty";
        description = ''
          Nome do emulador de terminal selecionado para o ambiente de trabalho.
          Pode ser qualquer terminal suportado (ex: "alacritty", "urxvt", "kitty", "foot", "wezterm", "xfce4-terminal", "ghostty", "st", "xterm")
          ou qualquer comando customizado presente no PATH.
        '';
      };

      command = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Comando de invocação customizado para o terminal (ex: "ghostty", "st -e tmux", "urxvtc").
          Se fornecido, substitui a geração automática de comando baseada em `name`.
        '';
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Pacote opcional do emulador de terminal a ser instalado em home.packages.";
      };

      activeCommand = mkOption {
        type = types.str;
        default = computedActiveCommand;
        description = "Comando executável agnóstico para invocar o terminal ativo em atalhos de WM e scripts.";
      };

      activeName = mkOption {
        type = types.str;
        default = activeName;
        description = "Nome amigável do terminal ativo para exibição em menus e manuais de atalhos.";
      };

      activeWorkingDirCommand = mkOption {
        type = types.str;
        default = computedWorkingDirCommand;
        description = "Comando base para abrir o terminal em um diretório de trabalho específico.";
      };

      scratchpadCommand = mkOption {
        type = types.str;
        default = computedScratchpadCommand;
        description = "Comando adaptado para abrir o terminal no modo flutuante/scratchpad.";
      };
    };
  };

  config = mkMerge [
    {
      # Disponibiliza o despachante agnóstico 'terminal' no PATH
      home.packages = [
        terminalDispatcher
      ]
      ++ (lib.optional (cfg.package != null) (nixGLWrapper cfg.package));

      # Define a variável de ambiente $TERMINAL para ferramentas do sistema
      home.sessionVariables = {
        TERMINAL = "terminal";
      };

      # Atalho de desktop agnóstico
      xdg.desktopEntries.terminal = {
        name = "Terminal";
        genericName = "Terminal Emulator";
        comment = "Agnostic Terminal Emulator";
        exec = "terminal %U";
        icon = "utilities-terminal";
        terminal = false;
        startupNotify = true;
        type = "Application";
        categories = [
          "System"
          "TerminalEmulator"
        ];
      };
    }

    # Wrapper ~/.local/bin/term caso URxvt/RXVT não esteja gerenciando ~/.local/bin/term
    (mkIf (!isUrxvt) {
      home.file.".local/bin/term" = {
        executable = true;
        text = ''
          #!/bin/sh
          exec ${terminalDispatcher}/bin/terminal "$@"
        '';
      };
    })
  ];
}
