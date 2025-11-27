{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf getExe;
  cfg = config.system.programs.shell;
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
        strategy = [ "history" "completion" "match_prev_cmd" ];
      };
      syntaxHighlighting = {
        enable = false;
        highlighters = [ "main" "brackets" "pattern" "cursor" "regexp" "root" "line" ];
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
        ignorePatterns = [ "rm *" "pkill *" "cp *" "ls" "ll" "la" "pwd" "history" "exit" "clear" "cd" ];
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
      '';
      # Plugins
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "z" ];
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
