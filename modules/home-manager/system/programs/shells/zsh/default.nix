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
  config = mkIf (cfg.default == "zsh") {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      dotDir = "$HOME/.config/zsh";
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
        bindkey '^p' history-serach-backward
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
              echo -e "\n❌ Erro no home-manager switch (código $exit_code)!\n📋 Log de erro: $error_file\n🔗 Atalho: $error_dir/last-error.log"
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
              echo -e "\n❌ Erro no nixos-rebuild $action (código $exit_code)!\n📋 Log de erro: $error_file\n🔗 Atalho: $error_dir/last-error.log"
            fi
            rm -f "$tmp_log" 2>/dev/null || true
            return $exit_code
          else
            command nixos-rebuild "$@"
          fi
        }
      '';
      # Plugins
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "z"
        ];
        extraConfig = ''
          # don't sort git branches
          zstyle ':completion:*:git-checkout:*' sort false

          # set descriptions format to enable group support
          # NOTE: don't use escape sequences here, fzf-tab will ignore them
          zstyle ':completion:*:descriptions' format '[%d]'

          # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
          #zstyle ':completion:*' menu no

          # preview directory's content with eza when completing cd
          zstyle ':fzf-tab:complete:cd:*' fzf-preview '${pkgs.eza} -1 --color=always $realpath'
          zstyle ':fzf-tab:complete:z:*' fzf-preview '${pkgs.eza} -1 --color=always $realpath'
          zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
          zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
          zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

          # switch group using `<` and `>`
          zstyle ':fzf-tab:*' switch-group '<' '>'
        '';
      };
    };
  };
}
