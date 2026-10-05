{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.shells;
in
{
  config = mkIf (cfg.enable && cfg.default == "fish") {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';

      functions = {
        fcd = {
          description = "Fuzzy change directory com preview dinâmico de árvore eza";
          body = ''
            set -l dir (fd --type d --hidden --exclude .git --exclude .cache 2>/dev/null | fzf --preview 'eza --tree --level=2 --color=always --icons {} 2>/dev/null | head -100' --preview-window 'right:50%:wrap')
            if test -n "$dir"
              cd $dir
            end
          '';
        };
      };
    };
  };
}
