{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe;
  cfg = config.system.programs.shells;
in
{
  config = mkIf (cfg.default == "bash") {
    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
        historyControl = [
          "erasedups"
          "ignoredups"
          "ignorespace"
        ];
        historyFile = "$HOME/.bash_history";
        historyFileSize = 10000;
        historyIgnore = [
          "ls"
          "pwd"
          "clear"
          "cd"
          "exit"
          "kill"
          "htop"
          "top"
          "btop"
          "btm"
          "neofetch"
        ];
        initExtra = ''
          if [ -d "$HOME/.bashrc.d" ] ; then
            for script in $HOME/.bashrc.d/* ; do
              source $script
            done
          fi

          "${getExe pkgs.nitch}"

          parse_git_branch() {
            git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\[(\1)\]/'
          }
        '';
        sessionVariables = {
          TERM = "xterm-256color"; # "xterm";
        };
      };
    };
  };
}
