{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption getExe;
  cfg = config.programs.terminal.console.fzf;
in
{
  options = {
    programs.terminal.console.fzf = {
      enable = mkEnableOption "Enable's fzf and configs.";
    };
  };
  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      # defaultOptions = [ ''--preview 'bat --plain --color=always "{}"' '' ];
      defaultCommand = "${getExe pkgs.fd} --hidden --strip-cwd-prefix --exclude .git";
      # fileWidgetOptions = [
      #   "--preview 'if [ -d {} ]; then ${pkgs.eza}/bin/eza --tree --color=always {} | head -200; else ${getExe pkgs.bat} -n --color=always --line-range :500 {}; fi'"
      # ];
      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range :300 {}'"
        "--color=light"
      ];
      fileWidgetCommand = "${getExe pkgs.fd} -H --color=always --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "${getExe pkgs.fd} --type=d --hidden --strip-cwd-prefix --exclude .git";
      changeDirWidgetOptions = [
        "--preview '${pkgs.eza}/bin/eza --tree --color=always {} | head -200'"
        "--exact"
      ];
      historyWidgetOptions = [
        "--sort"
      ];
      ## Theme
      defaultOptions = [
        "--color=fg:-1,fg+:#FBF1C7,bg:-1,bg+:#282828"
        "--color=hl:#98971A,hl+:#B8BB26,info:#928374,marker:#D65D0E"
        "--color=prompt:#CC241D,spinner:#689D6A,pointer:#D65D0E,header:#458588"
        "--color=border:#665C54,label:#aeaeae,query:#FBF1C7"
        "--border='rounded' --border-label='' --preview-window='border-rounded' --prompt='> '"
        "--marker='>' --pointer='>' --separator='─' --scrollbar='│'"
        "--height 50%"
        "--info='right'"
      ];
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
  };
}
