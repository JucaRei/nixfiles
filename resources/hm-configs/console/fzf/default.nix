{ pkgs, ... }: {
  programs.fzf = {
    enable = true;
    # defaultOptions = [ ''--preview 'bat --plain --color=always "{}"' '' ];
    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    fileWidgetOptions = [
      "--preview 'if [ -d {} ]; then ${pkgs.eza}/bin/eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
    ];
    changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --color=always {} | head -200'"
    ];
    ## Theme
    defaultOptions = [
      "--color=fg:-1,fg+:#FBF1C7,bg:-1,bg+:#282828"
      "--color=hl:#98971A,hl+:#B8BB26,info:#928374,marker:#D65D0E"
      "--color=prompt:#CC241D,spinner:#689D6A,pointer:#D65D0E,header:#458588"
      "--color=border:#665C54,label:#aeaeae,query:#FBF1C7"
      "--border='rounded' --border-label='' --preview-window='border-rounded' --prompt='> '"
      "--marker='>' --pointer='>' --separator='─' --scrollbar='│'"
      "--info='right'"
    ];
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };
}
