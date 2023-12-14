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
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        unstage = "reset HEAD --";
        quick-rebase = "rebase --interactive --autostash --committer-date-is-author-date";
        quick-clone = "clone --depth=1 --recurse-submodules --shallow-submodules";
      };

      extraConfig = {
        push = {
          default = "matching";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
        # Shorthand for popular forges ala-Nix flake URL inputs. It's just a fun
        # little part of the config.
        url = {
          "https://github.com/".insteadOf = [ "gh:" "github:" ];
          "https://gitlab.com/".insteadOf = [ "gl:" "gitlab:" ];
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
        "*.log"
        "*.out"
        ".DS_Store"
        "bin/"
        "dist/"
        "result"
      ];
    };
  };
}
