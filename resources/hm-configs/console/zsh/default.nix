{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.console.zsh;
in
{
  options = {
    console.zsh = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's zsh with configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
        dotDir = ".config/zsh";
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
        # dirHashes = {
        #   dots = "$HOME/.dotfiles/nixfiles";
        #   docs = "$HOME/Documents";
        #   down = "$HOME/Downloads";
        #   # paperwork = "$HOME/Documents/Work/Paperwork";
        #   work = "$HOME/Documents/Work";
        #   personal = "$HOME/Documents/Personal";
        # };

        # plugins = [{
        #   name = "fast-syntax-highlighting";
        #   src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
        # }
        #   {
        #     name = "zsh-nix-shell";
        #     src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
        #   }
        #   {
        #     name = "zsh-fzf-tab";
        #     src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        #     file = "fzf-tab.plugin.zsh";
        #   }];
        # envExtra = "ZSH_DISABLE_COMPFIX=true";

        history = {
          # Record timestamp
          extended = true;
          # If a new command line being added to the history list duplicates an
          # older one, the older command is removed from the list (even if it is
          # not the previous event)
          ignoreAllDups = true;
          # Do not enter command lines into the history list if they are duplicates
          # of the previous event
          ignoreDups = true;
          # Do not enter command lines into the history list if the first character
          # is a space
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
          # Share command history between zsh sessions
          share = true;
          # Number of history lines to keep in memory
          size = 10000;
          # Number of history lines to save to the history file
          save = 10000;
        };

        #######################
        ### Plugin Managers ###
        #######################

        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "sudo"
            "z"

          ];
          # theme = "awesomepanda";
          # theme = "afowler";
          # theme = "steeef";
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

        # zplug = {
        #   enable = true;
        #   plugins = [
        #     { name = "zsh-users/zsh-autosuggestions"; }
        #     { name = "chisui/zsh-nix-shell"; }
        #     { name = "zsh-users/zsh-syntax-highlighting"; }
        #     { name = "zsh-users/zsh-history-substring-search"; }
        #     { name = "ptavares/zsh-direnv"; }
        #   ];
        # };

        # antidote = {
        #   enable = true;
        #   useFriendlyNames = true;
        #   plugins = [
        #     # "agnoster/agnoster-zsh-theme"

        #     # "zdharma-continuum/fast-syntax-highlighting"
        #     # "marlonrichert/zsh-autocomplete"
        #     "zsh-users/zsh-syntax-highlighting"
        #     "robbyrussell/oh-my-zsh path:plugins/git"
        #     "robbyrussell/oh-my-zsh path:plugins/command-not-found"
        #     "robbyrussell/oh-my-zsh path:plugins/common-aliases"
        #     "romkatv/powerlevel10k"
        #     "Aloxaf/fzf-tab"
        #     "unixorn/fzf-zsh-plugin"
        #   ];
        # };
        # source ${pkgs.spaceship-prompt}/share/zsh/themes/spaceship.zsh-theme;
        initExtra = ''
          bindkey '^p' history-serach-backward
          bindkey '^n' history-search-forward
          bindkey '^y' autosuggest-accept

          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' menu no

        '';
        # [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh ]]
        # [[ ! -f ~/.config/zsh/.zshrc ]] || source ~/.config/zsh/.zshrc ]]

      };
    };
    home = {
      # packages = with pkgs ; [ perl ];
      #   activation = {
      #     zshBefore = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      #       rm -f $XDG_CONFIG_HOME/zsh/.zshenv
      #     '';
      #     zshAfter = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      #       rm -f $HOME/.config/zsh/.zshenv

      #       zshenvPath="$XDG_CONFIG_HOME/zsh/.zshenv"
      #       if [ -f "$zshenvPath" ]; then
      #         sed -i 's|\.nix-profile/|\.local/state/nix/profile/|g' "$zshenvPath"
      #       fi
      #     '';
      #   };
    };
  };
}
