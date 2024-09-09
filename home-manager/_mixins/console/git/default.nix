{ lib, config, pkgs, ... }:
let
  inherit (lib) mkOption mkIf types optionalString mdDoc;
  cfg = config.services.git;

  makeGitConfig =
    { userName
    , userEmail
    , githubUser
    , signingKey
    ,
    }: pkgs.writeText "config" (
      ''
        [user]
          name = "${userName}"
          email = "${userEmail}"
          ${
            optionalString (signingKey != null) ''
              signingKey = "${signingKey}"
            ''
          }
      ''
      +
      optionalString (githubUser != null) ''
        [github]
          username = "${githubUser}"
      ''
    );

  defaultIdentity = {
    email = "reinaldo800@gmail.com";
    fullName = "Reinaldo P Jr";
    githubUser = "Reinaldo";
    # signingKey = "5B3390B01C01D3E";
    conditions = [
      "hasconfig:remote.*.url:git@github.com:JucaRei/**"
      "hasconfig:remote.*.url:https://github.com/JucaRei/**"
      # "gitdir:~/work2/foss/"
      # "gitdir:~/work2/learning/"
      # "gitdir:~/work2/personal/"
      # "gitdir:~/work2/prototypes/"
      # "gitdir:/assets/"
      # "gitdir:/git-annex/"
    ];
  };

  identityType = types.submodule {
    options = {
      email = mkOption {
        type = types.str;
        description = mdDoc "E-mail address of the user";
      };
      fullName = mkOption {
        type = types.str;
        description = mdDoc "Full name of the user";
      };
      githubUser = mkOption {
        type = types.nullOr types.str;
        description = mdDoc "GitHub login of the user";
        default = null;
      };
      signingKey = mkOption {
        type = types.nullOr types.str;
        description = mdDoc "GPG signing key";
        default = null;
      };
      conditions = mkOption {
        type = types.listOf types.str;
        description = mdDoc "List of include conditions";
      };
    };
  };
in
{
  options.services.git = {
    enable = mkOption {
      default = true;
      type = types.bool;
      description = mdDoc "Enable git by Default";
    };

    defaultIdentity = mkOption {
      type = types.nullOr identityType;
      description = mdDoc "Default identity";
      default = defaultIdentity;
    };

    extraIdentities = mkOption {
      type = types.listOf identityType;
      description = lib.mdDoc "Extra list of identities";
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
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

          # Log
          l = "log --topo-order --pretty=format:'%C(yellow)%h %C(cyan)%cn %C(blue)%cr%C(reset) %s'";
          ls = "log --topo-order --stat --pretty=format:'%C(bold)%C(yellow)Commit:%C(reset) %C(yellow)%H%C(red)%d%n%C(bold)%C(yellow)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)%C(yellow)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'";
          ld = "log --topo-order --stat --patch --full-diff --pretty=format:'%C(bold)%C(yellow)Commit:%C(reset) %C(yellow)%H%C(red)%d%n%C(bold)%C(yellow)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)%C(yellow)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'";
          lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          lga = "log --topo-order --all --graph --pretty=format:'%C(yellow)%h %C(cyan)%cn%C(reset) %s %C(red)%d%C(reset)%n'";
          lm = "log --topo-order --pretty=format:'%s'";
          lh = "shortlog --summary --numbered";
          llf = "fsck --lost-found";

          lg1 = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
          lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";

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

          # Increase the size of post buffers to prevent hung ups of git-push.
          # https://stackoverflow.com/questions/6842687/the-remote-end-hung-up-unexpectedly-while-git-cloning#6849424
          http.postBuffer = "524288000";
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
        includes = lib.pipe ([ cfg.defaultIdentity ] ++ cfg.extraIdentities) [
          (builtins.filter (v: v != null))
          (builtins.map (
            { email
            , fullName
            , githubUser
            , signingKey
            , conditions
            ,
            }:
            let
              configFile = makeGitConfig {
                inherit githubUser signingKey;
                userName = fullName;
                userEmail = email;
              };
            in
            builtins.map
              (condition: {
                path = configFile;
                inherit condition;
              })
              conditions
          ))
          lib.flatten
        ];
      };
    };
  };
}
