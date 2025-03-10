{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.shell.zsh;
in
{
  options = {
    programs.terminal.shell.zsh = {
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
        autosuggestion = {
          enable = true;
          strategy = [ "history" "completion" "match_prev_cmd" ];
          highlightStyle = "fg=#50FA7B,bold";
        };
        syntaxHighlighting = {
          enable = false;
          highlighters = [ "main" "brackets" "pattern" "cursor" "regexp" "root" "line" ];
        };
        autocd = true;
        dirHashes = {
          dots = "$HOME/.dotfiles/nixfiles";
          docs = "$HOME/Documents";
          down = "$HOME/Downloads";
          # paperwork = "$HOME/Documents/Work/Paperwork";
          work = "$HOME/Documents/Work";
          personal = "$HOME/Documents/Personal";
        };
        # oh-my-zsh = {
        #   enable = true;
        #   plugins = [ "git" "sudo" ];
        #   theme = "afowler";
        #   # theme = "steeef";
        # };
        antidote = {
          enable = true;
          plugins = [
            "zdharma-continuum/fast-syntax-highlighting"
            "ohmyzsh/ohmyzsh path:lib/git.zsh"
            "ohmyzsh/ohmyzsh path:lib/clipboard.zsh"
            "ohmyzsh/ohmyzsh path:plugins/aliases"
            "ohmyzsh/ohmyzsh path:plugins/copypath"
            "ohmyzsh/ohmyzsh path:plugins/colored-man-pages"
            "ohmyzsh/ohmyzsh path:plugins/extract"
            "ohmyzsh/ohmyzsh path:plugins/git"
            "ohmyzsh/ohmyzsh path:plugins/git-extras"
            "ohmyzsh/ohmyzsh path:plugins/magic-enter"
            "ohmyzsh/ohmyzsh path:plugins/npm"
            "ohmyzsh/ohmyzsh path:plugins/pyenv"
            "ohmyzsh/ohmyzsh path:plugins/python"
            # "ohmyzsh/ohmyzsh path:plugins/tmux"
            # "jeffreytse/zsh-vi-mode"
            "djui/alias-tips"
            # "dim-an/cod"
            # "wfxr/forgit"
            # "MichaelAquilina/zsh-autoswitch-virtualenv"
            "chisui/zsh-nix-shell"
            "nix-community/nix-zsh-completions"

            "zsh-users/zsh-history-substring-search"
            "mafredri/zsh-async"
            # "robbyrussell/oh-my-zsh path:plugins/gitfast"
            # "robbyrussell/oh-my-zsh path:plugins/colored-man-pages"
            # Theme
            "sindresorhus/pure"
          ];
        };
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
          # Share command history between zsh sessions
          share = true;
          # Number of history lines to keep in memory
          size = 10000;
          # Number of history lines to save to the history file
          save = 10000;
        };
      };
    };
  };
}
