{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.custom.console.bash;
in
{
  # imports = [ ./starship ];

  options.custom.console.bash = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # custom.console.starship.enable = lib.mkDefault true;
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
        '';
        sessionVariables = {
          # TERM = "xterm";
          TERM = "xterm-256color";
        };
      };
    };

    home.packages = [ pkgs.bashInteractive ];
  };
}
