{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.custom.console.skim;
in
{
  options.custom.console.skim = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    programs.skim = rec {
      enable = true;
      defaultCommand = "fd --type f --hidden --exclude '.git'";
      defaultOptions = [
        "--height 40%"
        "--inline-info"
        "--color=matched:#d7d7d5,matched_bg:#ea00d9,current_bg:#091833,current_match_bg:#711c91,info:#0abdc6,border:#ea00d9,prompt:#ea00d9,pointer:#ea00d9,spinner:#00ff00"
      ];
      changeDirWidgetCommand = "fd --type d --hidden --exclude '.git'";
      fileWidgetCommand = defaultCommand;
      fileWidgetOptions = [
        "--preview 'bat --color always {} 2> /dev/null | head -200; highlight -O ansi -l {} ^ /dev/null | head -200 || cat {} ^ /dev/null | head -200'"
      ];
      historyWidgetOptions = [ "--tac" ];
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    # Use skim as a drop-in replacement for fzf
    home.packages = with pkgs; [
      (writeShellApplication {
        name = "fzf";
        runtimeInputs = [ skim ];
        text =
          # shell
          ''
            ${pkgs.skim}/bin/sk "\$@"
          '';
      })
    ];
  };
}
