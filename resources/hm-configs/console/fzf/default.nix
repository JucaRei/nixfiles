{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption getExe;
  cfg = config.console.fzf;
in
{
  options = {
    console.fzf = {
      enable = mkEnableOption "Enable's fzf and configs.";
    };
  };
  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      changeDirWidgetCommand = "${getExe pkgs.fd} --type=d --hidden --strip-cwd-prefix --exclude .git";
      changeDirWidgetOptions = [
        "--preview '${pkgs.eza}/bin/eza --tree --color=always {} | head -200'"
      ];
      defaultCommand = "${getExe pkgs.fd} --hidden --strip-cwd-prefix --exclude .git";
      fileWidgetOptions = [
        "--preview 'if [ -d {} ]; then ${pkgs.eza}/bin/eza --tree --color=always {} | head -200; else ${getExe config.programs.bat.package} -n --color=always --line-range :500 {}; fi'"
      ];

      colors = {
        bg = "#24273a";
        "bg+" = "#363a4f";
        spinner = "#f4dbd6";
        hl = "#ed8796";
        fg = "#cad3f5";
        header = "#ed8796";
        info = "#c6a0f6";
        pointer = "#f4dbd6";
        marker = "#f4dbd6";
        "fg+" = "#cad3f5";
        prompt = "#c6a0f6";
        "hl+" = "#ed8796";
      };
      ## Theme
      defaultOptions = [
        "--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"
        "--preview 'cat {}'"

        # "--color=fg:-1,fg+:#FBF1C7,bg:-1,bg+:#282828"
        # "--color=hl:#98971A,hl+:#B8BB26,info:#928374,marker:#D65D0E"
        # "--color=prompt:#CC241D,spinner:#689D6A,pointer:#D65D0E,header:#458588"
        # "--color=border:#665C54,label:#aeaeae,query:#FBF1C7"
        # "--border='double' --border-label='' --preview-window='border-sharp' --prompt='> '"
        # "--marker='>' --pointer='>' --separator='─' --scrollbar='│'"
        # "--info='right'"
      ];
  
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    home.shellAliases = {
      fpreview = ''${pkgs.neovim}/bin/nvim $(fzf --preview="${getExe config.programs.bat.package} --color=always --line-range :500 {}")'';
    };
  };
}
