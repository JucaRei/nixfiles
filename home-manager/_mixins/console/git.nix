{ pkgs, ... }: {
  programs = {
    gh = {
      enable = true;
      extensions = with pkgs.unstable; [ gh-markdown-preview ];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };

    git = {
      enable = true;
      delta = {
        enable = true;
        options = {
          features = "decorations";
          navigate = true;
          side-by-side = true;
        };
      };

      aliases = {
        lg =
          "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        lg2 = ''
          log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';

        unstage = "reset HEAD --";
        rbase =
          "rebase --interactive --autostash --committer-date-is-author-date";
        clone = "clone --depth=1 --recurse-submodules --shallow-submodules";
      };

      extraConfig = {
        push = { default = "matching"; };
        pull = { rebase = true; };
        init = { defaultBranch = "main"; };
        # Shorthand for popular forges ala-Nix flake URL inputs. It's just a fun
        # little part of the config.
        url = {
          "https://github.com/".insteadOf = [ "gh:" "github:" ];
          "https://gitlab.com/".insteadOf = [ "gl:" "gitlab:" ];
          "https://gist.github.com/".insteadOf = [ "gist:" ];
          "https://bitbucket.org/".insteadOf = [ "bb:" ];
          "https://gitlab.gnome.org/".insteadOf = [ "gnome:" ];
          "https://invent.kde.org/".insteadOf = [ "kde:" ];
          "https://git.sr.ht/".insteadOf = [ "sh:" "sourcehut:" ];
          "https://git.savannah.nongnu.org/git/".insteadOf =
            [ "sv:" "savannah:" ];
        };
        status = {
          showPatch = true;
          showStash = true;
        };

        submodule.fetchJobs = 0;
      };

      ignores = [
        # General:
        "*.bloop"
        "*.bsp"
        "*.metals"
        "*.metals.sbt"
        "*metals.sbt"
        "*.direnv"
        "*.envrc"
        "*hie.yaml"
        "*.mill-version"
        "*.jvmopts"

        # Emacs:
        "*~"
        "*.*~"
        "\\#*"
        ".\\#*"

        # OS-related:
        ".DS_Store?"
        ".DS_Store"
        ".CFUserTextEncoding"
        ".Trash"
        ".Xauthority"
        "thumbs.db"
        "Thumbs.db"
        "Icon?"
        "*.log"
        "*.out"
        "bin/"
        "dist/"
        "result"

        # Compiled residues:
        "*.class"
        "*.exe"
        "*.o"
        "*.pyc"
        "*.elc"
      ];
    };
  };
}
