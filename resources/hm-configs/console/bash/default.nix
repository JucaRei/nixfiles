{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types getExe;
  cfg = config.console.bash;
in
{
  # imports = [ ./starship ];

  options.console.bash = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # console.starship.enable = lib.mkDefault true;
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
          # "histappend" ### Configure bash to append (rather than overwrite history)
          # "autocd"
          # "globstar"
          # "checkwinsize"
          # "cdspell"
          # "cmdhist" # Attempt to save all lines of a multiple-line command in the same entry
          # "dirspell"
          # "expand_aliases"
          # "dotglob"
          # "gnu_errfmt"
          # "histreedit"
          # "nocasematch"
        ];
        shellAliases = {
          gitpfolders = "for i in */.git; do ( echo $i; cd $i/..; git pull; ); done";
          search = ''
            "${pkgs.ripgrep}/bin/rg -p --glob "!node_modules/*" --glob "!vendor/*" "$@"'"
          '';
        };
        initExtra = ''
          ## History
          export HISTFILE=/$HOME/.bash_history
          ## Configure bash to append (rather than overwrite history)
          shopt -s histappend

          # Attempt to save all lines of a multiple-line command in the same entry
          shopt -s cmdhist

          ## After each command, append to the history file and reread it
          export PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND$"\n"}history -a; history -c; history -r"

          ## Print the timestamp of each command
          HISTTIMEFORMAT="%Y%m%d.%H%M%S%z "

          ## Set History File Size
          # HISTFILESIZE=2000000

          ## Set History Size in memory
          HISTSIZE=3000

          ## Don't save ls,ps, history commands
          export HISTIGNORE="ls:ll:ls -alh:pwd:clear:history:ps"

          ## Do not store a duplicate of the last entered command and any commands prefixed with a space
          HISTCONTROL=ignoreboth

          # if command -v "nmcli" &>/dev/null; then
          #   alias wifi_scan="nmcli device wifi rescan && nmcli device wifi list"  # rescan for network
          # fi

          # if command -v "tree" &>/dev/null; then
          #   alias tree="${getExe pkgs.tree} -Cs"
          # fi

          # if command -v "rsync" &>/dev/null; then
          #   alias rsync="${getExe pkgs.rsync} -aXxtv" # Better copying with Rsync
          # fi

          # if command -v "rg" &>/dev/null && command -v "fzf" &>/dev/null && command -v "bat" &>/dev/null; then
          #   function frg {
          #     result=$(${getExe pkgs.ripgrep} --ignore-case --color=always --line-number --no-heading "$@" |
          #       ${getExe pkgs.fzf} --ansi \
          #           --color 'hl:-1:underline,hl+:-1:underline:reverse' \
          #           --delimiter ':' \
          #           --preview "${getExe pkgs.bat} --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
          #           --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
          #     file="''${result%%:*}"
          #     linenumber=$(echo "''${result}" | cut -d: -f2)
          #     if [ ! -z "$file" ]; then
          #             $EDITOR +"''${linenumber}" "$file"
          #     fi
          #   }
          # fi

          if [ -d "$HOME/.bashrc.d" ] ; then
            for script in $HOME/.bashrc.d/* ; do
              source $script
            done
          fi

          # Quickly run a pkg run nixpkgs - Add a second argument to it otherwise it will simply run the command
          pkgrun () {
            # if [ -n $1 ] ; then
            if test -n $1  ; then
              local pkg
              pkg=$1
              # if [ "$2" != "" ] ; then
              if test "$2" != "" ; then
                shift
                local args

                args="$@"
                  else
                args=$pkg
              fi

              nix-shell -p $pkg.out --run "$args"
            fi
          }
        ''
        +
        ''
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
                *.tar.bz2)   tar xjf $1                               ;;
                *.tar.gz)    tar xzf $1                               ;;
                *.bz2)       bunzip2 $1                               ;;
                *.rar)       unrar x $1                               ;;
                *.gz)        gunzip $1                                ;;
                *.tar)       tar xf $1                                ;;
                *.tbz2)      tar xjf $1                               ;;
                *.tgz)       tar xzf $1                               ;;
                *.zip)       unzip $1                                 ;;
                *.Z)         uncompress $1                            ;;
                *.7z)        7z x $1                                  ;;
                *.deb)       ar x $1                                  ;;
                *.tar.xz)    tar xf $1                                ;;
                *.tar.zst)   tar xf $1                                ;;
                *)           echo "'$1' cannot be extracted via ex()" ;;
              esac
            else
              echo "'$1' is not a valid file"
            fi
          }

          # Reporting tools
          # =============================================
          # "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
          "${getExe pkgs.nitch}"
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

    home.packages = with pkgs; [
      bashInteractive
      nitch
      ripgrep
      # rsync
      # tree
      # fzf
    ];
  };
}
