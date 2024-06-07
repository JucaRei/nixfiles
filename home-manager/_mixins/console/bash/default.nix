{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.bash;
in
{
  # imports = [ ./starship ];

  options.services.bash = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # services.starship.enable = lib.mkDefault true;
    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
        historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
        historyFile = "$HOME/.bash_history";
        historyFileSize = 10000;
        historyIgnore = [ "ls" "cd" "exit" "kill" "htop" "top" "btop" "btm" "neofetch" ];
        shellOptions = [
          "histappend"
          "autocd"
          "globstar"
          "checkwinsize"
          "cdspell"
          "cmdhist"
          # "dirspell"
          "expand_aliases"
          "dotglob"
          "gnu_errfmt"
          # "histreedit"
          "nocasematch"
        ];
        shellAliases = {
          gitpfolders = "for i in */.git; do ( echo $i; cd $i/..; git pull; ); done";
          search = ''
            "${pkgs.ripgrep}/bin/rg -p --glob "!node_modules/*" --glob "!vendor/*" "$@"'"
          '';
        };
        initExtra = ''
          # Zsh-like completion
          # General
          # =============================================
          # ignore upper and lowercase when TAB completion
          bind "set completion-ignore-case on"
          bind "set show-all-if-ambiguous on"
          bind "TAB:menu-complete"

          # set vim keybindings
          set -o vi
          # fix ctrl+l not working when using vim keybinds
          bind -m vi-command 'Control-l: clear-screen'
          bind -m vi-insert 'Control-l: clear-screen'

          if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
          fi

          # ex = Extractor for all kinds of archives
          # =============================================
          # usage: ex <file>
          ex() {
            if [ -f $1 ] ; then
              case $1 in
                *.tar.bz2)   tar xjf $1   ;;
                *.tar.gz)    tar xzf $1   ;;
                *.bz2)       bunzip2 $1   ;;
                *.rar)       unrar x $1   ;;
                *.gz)        gunzip $1    ;;
                *.tar)       tar xf $1    ;;
                *.tbz2)      tar xjf $1   ;;
                *.tgz)       tar xzf $1   ;;
                *.zip)       unzip $1     ;;
                *.Z)         uncompress $1;;
                *.7z)        7z x $1      ;;
                *.deb)       ar x $1      ;;
                *.tar.xz)    tar xf $1    ;;
                *.tar.zst)   tar xf $1    ;;
                *)           echo "'$1' cannot be extracted via ex()" ;;
              esac
            else
              echo "'$1' is not a valid file"
            fi
          }

          # Reporting tools
          # =============================================
          # "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
          "${pkgs.nitch}/bin/nitch"
        '';

        bashrcExtra = ''
          parse_git_branch() {
            git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\[(\1)\]/'
          }
          # export PS1="\n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\[\033[33m\]\$(parse_git_branch)\[\033[1;32m\]\$\[\033[0m\] "

          # if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
          #   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          #   . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
          #   . /home/juca/.nix-profile/etc/profile.d/nix.sh
          #   . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
          #   # . /home/$USER/.nix-profile/etc/profile.d/nix.sh
          # fi

          # nix shortcuts
          shell() {
            nix-shell '<nixpkgs>' -A "$1"
          }

          # -------===[ External Plugins ]===------- #
          #eval "$(starship init bash)"
          #eval "$(direnv hook bash)"
        '';
        sessionVariables = { TERM = "xterm"; };
      };
    };
  };
}
