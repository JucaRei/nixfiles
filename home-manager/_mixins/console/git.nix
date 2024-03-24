_: {
  programs = {
    git = {
      enable = true;
      aliases = {
        ci = "commit";
        cl = "clone";
        clr = "clone --depth=1";
        co = "checkout";
        purr = "pull --rebase";
        dlog = "!f() { GIT_EXTERNAL_DIFF=difft git log -p --ext-diff $@; }; f";
        dshow = "!f() { GIT_EXTERNAL_DIFF=difft git show --ext-diff $@; }; f";
        fucked = "reset --hard";
        graph = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
      difftastic = {
        display = "side-by-side-show-both";
        enable = true;
      };
      extraConfig = {
        advice = { statusHints = false; };
        color = {
          branch = false;
          diff = false;
          interactive = true;
          log = false;
          status = true;
          ui = false;
        };
        core = { pager = "bat"; };
        push = { default = "matching"; };
        pull = { rebase = false; };
        init = { defaultBranch = "main"; };
        url = {
          "https://github.com/".insteadOf = [ "gh:" "github:" ];
          "https://gitlab.com/".insteadOf = [ "gl:" "gitlab:" ];
          "https://gist.github.com/".insteadOf = [ "gist:" ];
          "https://bitbucket.org/".insteadOf = [ "bb:" ];
          "https://gitlab.gnome.org/".insteadOf = [ "gnome:" ];
          "https://invent.kde.org/".insteadOf = [ "kde:" ];
          "https://git.sr.ht/".insteadOf = [ "sh:" "sourcehut:" ];
          "https://git.savannah.nongnu.org/git/".insteadOf = [ "sv:" "savannah:" ];
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
