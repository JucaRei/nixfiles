{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    system = {
      programs = {
        console = {
          bat.enable = true;
          eza.enable = true;
        };
        browsers = {
          firefox.enable = true;
        };
        editors = {
          vscode = {
            enable = true;
            enableConfigurableSettings = true;
          };
        };
        terminal = {
          enable = true;
          name = "alacritty";
        };
      };
    };

    # Adiciona a extensão Continue (Chat + Autocomplete com Gemini) especificamente na Rocinante
    programs.vscode.profiles.default.extensions =
      lib.mkIf config.system.programs.editors.vscode.enable (
        pkgs.nix4vscode.forVscode [
          "Continue.continue"
        ]
      );

    # Teclado Apple: swap_opt_cmd=0 no kernel já define Command = Super (Mod4) e Option = Alt (Mod1) nativamente

    home.packages = with pkgs; [
      direnv
      brightnessctl
      pamixer
      pavucontrol
      eza
      bat
      duf
      fzf
      ripgrep
      htop
      btop
    ];
  };
}
