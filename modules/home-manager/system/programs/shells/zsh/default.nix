{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.shells;
in
{
  config = mkIf (cfg.enable && cfg.default == "zsh") {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      dotDir = "${config.xdg.configHome}/zsh";
      envExtra = ''
        # Limpar variáveis legadas herdadas do ambiente de login antes do carregamento dos plugins
        unset FZF_TAB_OPTS FZF_TAB_COMMAND FZF_TAB_QUERY FZF_TAB_SINGLE_GROUP fzf_tab_preview_init 2>/dev/null || true
      '';
      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
          "match_prev_cmd"
        ];
      };
      syntaxHighlighting = {
        enable = false;
        highlighters = [
          "main"
          "brackets"
          "pattern"
          "cursor"
          "regexp"
          "root"
          "line"
        ];
        patterns = {
          unknown-token = "fg=magenta";
          WORDCHARS = "*?_-.[]~=&;!#$%^(){}<>";
        };
      };
      autocd = true;
      history = {
        extended = true;
        ignoreAllDups = true;
        ignoreDups = true;
        ignoreSpace = true;
        ignorePatterns = [
          "rm *"
          "pkill *"
          "cp *"
          "ls"
          "ll"
          "la"
          "pwd"
          "history"
          "exit"
          "clear"
          "cd"
        ];
        share = true;
        size = 10000;
        save = 10000;
      };
      initExtra = ''
        bindkey '^p' history-search-backward
        bindkey '^n' history-search-forward
        bindkey '^y' autosuggest-accept

        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no

        # Wrappers com captura automática de logs de erro em ~/.config/errors/nix/
        home-manager() {
          if [[ "$1" == "switch" ]]; then
            local error_dir="$HOME/.config/errors/nix/home-manager"
            mkdir -p "$error_dir"
            local tmp_log
            tmp_log=$(mktemp /tmp/hm-switch-XXXXXX.log 2>/dev/null || echo "/tmp/hm-switch-$$.log")
            command home-manager "$@" 2>&1 | tee "$tmp_log"
            local exit_code=''${pipestatus[1]}
            if [[ $exit_code -ne 0 ]]; then
              local timestamp
              timestamp=$(date +%Y-%m-%d_%H-%M-%S)
              local error_file="$error_dir/switch-error-$timestamp.log"
              cp "$tmp_log" "$error_file" 2>/dev/null || true
              ln -sf "$error_file" "$error_dir/last-error.log" 2>/dev/null || true
              echo -e "\n󰅖  Erro no home-manager switch (código $exit_code)!\n󰈙  Log de erro: $error_file\n󰌷  Atalho: $error_dir/last-error.log"
            fi
            rm -f "$tmp_log" 2>/dev/null || true
            return $exit_code
          else
            command home-manager "$@"
          fi
        }

        nixos-rebuild() {
          if [[ "$1" == "switch" || "$1" == "boot" ]]; then
            local action="$1"
            local error_dir="$HOME/.config/errors/nix/nixos"
            mkdir -p "$error_dir"
            local tmp_log
            tmp_log=$(mktemp /tmp/nixos-rebuild-XXXXXX.log 2>/dev/null || echo "/tmp/nixos-rebuild-$$.log")
            command nixos-rebuild "$@" 2>&1 | tee "$tmp_log"
            local exit_code=''${pipestatus[1]}
            if [[ $exit_code -ne 0 ]]; then
              local timestamp
              timestamp=$(date +%Y-%m-%d_%H-%M-%S)
              local error_file="$error_dir/$action-error-$timestamp.log"
              cp "$tmp_log" "$error_file" 2>/dev/null || true
              ln -sf "$error_file" "$error_dir/last-error.log" 2>/dev/null || true
              echo -e "\n󰅖  Erro no nixos-rebuild $action (código $exit_code)!\n󰈙  Log de erro: $error_file\n󰌷  Atalho: $error_dir/last-error.log"
            fi
            rm -f "$tmp_log" 2>/dev/null || true
            return $exit_code
          else
            command nixos-rebuild "$@"
          fi
        }

        # fcd: Fuzzy change directory com preview dinâmico de árvore eza
        fcd() {
          local dir
          dir=$(fd --type d --hidden --exclude .git --exclude .cache 2>/dev/null | fzf --preview 'eza --tree --level=2 --color=always --icons {} 2>/dev/null | head -200' --preview-window 'right:65%:wrap')
          if [ -n "$dir" ]; then
            cd "$dir" || return
          fi
        }
      '';

      # Plugins externos via Nixpkgs
      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];

      # Oh-My-Zsh e Configurações avançadas do fzf-tab
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "z"
        ];
        extraConfig = ''
          # Limpar variáveis legadas herdadas de processos pais que acionam aviso do fzf-tab (PR #132)
          unset FZF_TAB_OPTS FZF_TAB_COMMAND FZF_TAB_QUERY FZF_TAB_SINGLE_GROUP fzf_tab_preview_init 2>/dev/null || true

          # Não reordenar branches git
          zstyle ':completion:*:git-checkout:*' sort false

          # Formato de descrições e agrupamento para o fzf-tab
          zstyle ':completion:*:descriptions' format '[%d]'

          # Dimensões e comportamento responsivo do fzf-tab:
          # Garante altura proporcional à janela do terminal (85%) e mínimo de 25 linhas,
          # fazendo a janela de preview de texto/scripts expandir conforme o tamanho do terminal.
          zstyle ':fzf-tab:*' fzf-min-height 25
          zstyle ':fzf-tab:*' fzf-pad 4
          zstyle ':fzf-tab:*' fzf-flags '--height=85%' '--min-height=25' '--preview-window=right:65%:wrap'
          zstyle ':fzf-tab:complete:*:*' fzf-flags '--height=85%' '--min-height=25' '--preview-window=right:65%:wrap'

          # Atalhos dentro do fzf-tab (alternar preview, redimensionar janela e scroll)
          zstyle ':fzf-tab:*' fzf-bindings 'ctrl-/:toggle-preview' 'ctrl-p:change-preview-window(right:80%|right:65%|right:50%|hidden)' 'ctrl-u:preview-half-page-up' 'ctrl-d:preview-half-page-down'
          zstyle ':fzf-tab:*' switch-group '<' '>'
          zstyle ':fzf-tab:*' prefix ""

          # Preview de diretórios ao dar tab em cd ou z
          zstyle ':fzf-tab:complete:(cd|z):*' fzf-preview '${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons $realpath 2>/dev/null | head -100'

          # Preview de arquivos genéricos usando bat com syntax highlighting completo
          zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [ -d "$realpath" ]; then ${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons "$realpath" 2>/dev/null | head -100; elif [ -f "$realpath" ]; then ${pkgs.bat}/bin/bat --style=numbers,changes --color=always --line-range :500 "$realpath" 2>/dev/null || head -n 500 "$realpath"; fi'

          # Preview de serviços systemd com cores nativas
          zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null'

          # Preview de processos para kill e ps com informações completas
          zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
          zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o user,pid,ppid,%cpu,%mem,stat,start,time,command -w -w'
          zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:4:wrap

          # Preview para git checkout e git log
          zstyle ':fzf-tab:complete:git-(checkout|switch):*' fzf-preview 'git log --color=always --oneline --graph -n 10 $word 2>/dev/null'
          zstyle ':fzf-tab:complete:git-(show|diff):*' fzf-preview 'git show --color=always $word 2>/dev/null'
        '';
      };
    };
  };
}
