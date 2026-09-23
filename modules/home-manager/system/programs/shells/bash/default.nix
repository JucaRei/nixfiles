{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    getExe
    mkOption
    mkMerge
    mkOrder
    types
    ;
  cfg = config.system.programs.shells;
  bashCfg = cfg.bash;
in
{
  options.system.programs.shells.bash = {
    blesh = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar ble.sh (Bash Line Editor) para predições de histórico, auto-sugestões e completude estilo Fish/Zsh.";
      };
    };
  };

  config = mkIf (cfg.enable && cfg.default == "bash") {
    home.packages = lib.optional bashCfg.blesh.enable pkgs.blesh;

    programs.bash = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];
      historyFile = "$HOME/.bash_history";
      historySize = 50000;
      historyFileSize = 100000;
      historyIgnore = [
        "ls"
        "pwd"
        "clear"
        "cd"
        "exit"
        "kill"
        "htop"
        "top"
        "btop"
        "btm"
        "neofetch"
      ];

      initExtra = mkMerge [
        # 1. Carregamento inicial do ble.sh (antes de prompts / starship)
        (mkOrder 500 ''
          # --- ble.sh: Inicialização antecipada (estilo Fish/Zsh) ---
          ${lib.optionalString bashCfg.blesh.enable ''
            if [[ $- == *i* ]] && [ -f "${pkgs.blesh}/share/blesh/ble.sh" ]; then
              source "${pkgs.blesh}/share/blesh/ble.sh" --attach=none

              # Ajustes de comportamento e predição estilo Fish
              bleopt complete_auto_delay=50       # 50ms para sugerir comandos do histórico
              bleopt complete_auto_history=1      # Predição de histórico em texto fantasma
              bleopt complete_auto_menu=1         # Exibe menu interativo de completude
              bleopt complete_menu_complete=1     # Tab navega pelas opções do menu
              bleopt complete_menu_filter=1       # Permite filtrar opções digitando
              bleopt highlight_syntax=1           # Destaque de sintaxe em tempo real
              bleopt highlight_filename=1         # Cores para arquivos e diretórios
              bleopt edit_abell=0                 # Silencia o beep do terminal
            fi
          ''}
        '')

        # 2. Configurações gerais de ambiente, scripts, shopts e fallback do Readline
        (mkOrder 1000 ''
          if [ -d "$HOME/.bashrc.d" ] ; then
            for script in $HOME/.bashrc.d/* ; do
              source "$script"
            done
          fi

          if [[ $- == *i* ]]; then
            "${getExe pkgs.nitch}"
          fi

          parse_git_branch() {
            git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\[(\1)\]/'
          }

          # --- Comportamento estilo Zsh / Fish ---
          shopt -s autocd 2>/dev/null || true       # 'pasta' entra direto nela sem precisar digitar cd
          shopt -s cdspell 2>/dev/null || true      # Corrige erros pequenos de digitação ao dar cd
          shopt -s checkwinsize 2>/dev/null || true # Atualiza tamanho de linhas/colunas do terminal
          shopt -s histappend 2>/dev/null || true   # Adiciona ao histórico em vez de sobrescrever
          shopt -s cmdhist 2>/dev/null || true      # Salva comandos multilinha em uma entrada única

          # --- Fallback do Readline (Completude e busca de histórico com setas) ---
          bind 'set completion-ignore-case on'
          bind 'set show-all-if-ambiguous on'
          bind 'set show-all-if-unmodified on'
          bind 'set menu-complete-display-prefix on'
          bind 'set colored-stats on'
          bind 'set colored-completion-prefix on'
          bind 'set mark-symlinked-directories on'
          bind 'set match-hidden-files off'

          # Setas Cima / Baixo buscam no histórico pelo que já foi digitado
          bind '"\e[A": history-search-backward'
          bind '"\e[B": history-search-forward'
          bind '"\e[1;5A": history-search-backward'
          bind '"\e[1;5B": history-search-forward'

          # Tab navega no menu, Shift-Tab volta
          bind 'TAB:menu-complete'
          bind '"\e[Z": menu-complete-backward'
        '')

        # 3. Acoplamento final do ble.sh (após Starship e PROMPT_COMMAND)
        (mkOrder 2000 ''
          ${lib.optionalString bashCfg.blesh.enable ''
            # Acoplar o editor ble.sh ao terminal interativo
            if [[ $- == *i* && -n "''${BLE_VERSION-}" ]]; then
              ble-attach
            fi
          ''}
        '')
      ];

      sessionVariables = {
        TERM = "xterm-256color";
      };
    };
  };
}
