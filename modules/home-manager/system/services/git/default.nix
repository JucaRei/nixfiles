{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.system.services.git;
in
{
  options = {
    system.services.git = {
      enable = lib.my.mkBool false "Enable git services.";

      userName = lib.my.mkStr "" "The default username.";

      userEmail = lib.my.mkStr "" "The default email.";

      signingKey =
        lib.my.mkOpt (lib.types.nullOr lib.types.str) "~/.ssh/nitro.pub"
          "Path to the SSH public key or GPG key ID used to sign commits.";

      signByDefault = lib.my.mkBool true "Whether to sign commits by default.";

      signingFormat = lib.my.mkEnum [
        "ssh"
        "openpgp"
        "x509"
      ] "ssh" "Format used for signing commits ('ssh', 'openpgp', or 'x509').";
    };
  };
  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;

        signing = mkIf (cfg.signingKey != null) {
          key = cfg.signingKey;
          inherit (cfg) signByDefault;
          format = cfg.signingFormat;
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

          # Conf
          ".direnv"
          ".vscode"

          # Ignore tags created by etags, ctags, gtags (GNU global) and cscope
          "TAGS"
          "!TAGS/"
          "tags"
          "!tags/"
          ".tags"
          ".tags1"
          "gtags.files"
          "tags.lock"
          "tags.temp"
          "GTAGS"
          "GRTAGS"
          "GPATH"
          "cscope.files"
          "cscope.out"
          "cscope.in.out"
          "cscope.po.out"

          # Vim
          "Session.vim"
          ".netrwhist"

          # OS-related:
          "Desktop.ini"
          ".DS_Store?"
          ".DS_Store"
          ".CFUserTextEncoding"
          ".Xauthority"
          "thumbs.db"
          "Thumbs.db"
          "Icon?"
          "*.log"
          "*.out"
          "bin/"
          "dist/"
          "result"

          # Eclipse
          "workbench.xmi"

          # IntelliJ
          ".idea/"

          # Files that micght appear on external disks
          ".Trash"
          ".Spotlight-V100"
          ".Trashes"

          # Compiled residues:
          "*.class"
          "*.exe"
          "*.o"
          "*.pyc"

        ];

        # lfs = {
        #   enable = true;
        #   skipSmudge = false;
        # };

        settings = {
          user = {
            name = cfg.userName;
            email = cfg.userEmail;
          };

          alias = {
            ci = "commit";
            cl = "clone";
            clr = "clone --depth=1";
            co = "checkout";
            purr = "pull --rebase";
            dlog = "!f() { GIT_EXTERNAL_DIFF=difft git log -p --ext-diff $@; }; f";
            dshow = "!f() { GIT_EXTERNAL_DIFF=difft git show --ext-diff $@; }; f";
            fucked = "reset --hard";
            graph = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";

            # Log
            l = "log --topo-order --pretty=format:'%C(yellow)%h %C(cyan)%cn %C(blue)%cr%C(reset) %s'";
            lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            ls = "log --topo-order --stat --pretty=format:'%C(bold)%C(yellow)Commit:%C(reset) %C(yellow)%H%C(red)%d%n%C(bold)%C(yellow)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)%C(yellow)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'";
            ld = "log --topo-order --stat --patch --full-diff --pretty=format:'%C(bold)%C(yellow)Commit:%C(reset) %C(yellow)%H%C(red)%d%n%C(bold)%C(yellow)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)%C(yellow)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'";
            lga = "log --topo-order --all --graph --pretty=format:'%C(yellow)%h %C(cyan)%cn%C(reset) %s %C(red)%d%C(reset)%n'";
            lm = "log --topo-order --pretty=format:'%s'";
            lh = "shortlog --summary --numbered";
            llf = "fsck --lost-found";

            lg1 = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
            plog = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";

            # remote
            r = "remote -v"; # show remotes (verbose)
          };

          init = {
            defaultBranch = "main";
          };
          "commit" = {
            verbose = true;
          };
          # "filter \"lfs\"" = {
          #   process = "git-lfs filter-process";
          #   required = true;
          #   clean = "git-lfs clean -- %f";
          #   smudge = "git-lfs smudge -- %f";
          # };
          advice = {
            statusHints = true;
          };
          apply = {
            whitespace = "nowarn";
          };
          color = {
            ui = true;
            status = true;
            interactive = true;
          };
          "color \"branch\"" = {
            current = "yellow reverse";
            local = "yellow";
            remote = "green";
          };
          "color \"diff\"" = {
            meta = "yellow bold";
            frag = "magenta bold";
            old = "red";
            new = "green";
          };
          diff = {
            mnemonicprefix = true;
            algorithm = "patience";
          };
          format = {
            pretty = "format:%C(blue)%ad%Creset %C(yellow)%h%C(green)%d%Creset %C(blue)%s %C(magenta) [%an]%Creset";
          };
          merge = {
            conflictstyle = "diff3";
            summary = true;
            verbosity = 1;
          };
          pull = {
            rebase = true;
            updateRefs = true;
            # ff = "only";
          };
          push = {
            default = "tracking";
          };
          rebase = {
            abbreviateCommands = true;
          };
          pack = {
            threads = 0;
          };

          # Increase the size of post buffers to prevent hung ups of git-push.
          # https://stackoverflow.com/questions/6842687/the-remote-end-hung-up-unexpectedly-while-git-cloning#6849424
          http.postBuffer = "524288000";

          url = {
            # "ssh://git@github.com/" = { insteadOf = "https://github.com/"; };
            # "https://github.com/" = { insteadOf = [ "gh" "https://github.com/" ]; };
            "ssh://git@github.com/" = {
              insteadOf = [
                "gh"
                "https://github.com/"
              ];
            };
            "https://gist.github.com/".insteadOf = [ "gist" ];
            "ssh://git@bitbucket.org/" = {
              insteadOf = [
                "bb"
                "https://bitbucket.org/"
              ];
            };
            "ssh://git@git.sr.ht/".insteadOf = [
              "sh"
              "https://git.sr.ht/"
            ];
          };
        };
      };
    };
  };
}
