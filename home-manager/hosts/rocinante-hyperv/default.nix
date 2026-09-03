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
        multimedia.mpv = {
          enable = true;
        };
      };
    };

    # Ativa compositor picom com animações para testes no Hyper-V
    desktop.bspwm = {
      picom = {
        enable = true;
        animations.enable = true;
      };
      # packages.extraPackages = with pkgs; [ libreoffice-qt ];
    };

    # Adiciona a extensão Continue (Chat + Autocomplete com Gemini) no VS Code do Hyper-V
    programs.vscode.profiles.default.extensions =
      lib.mkIf config.system.programs.editors.vscode.enable
        (
          pkgs.nix4vscode.forVscode [
            "Continue.continue"
          ]
        );

    home.packages = with pkgs; [
      direnv
      duf
      fzf
      ripgrep
      htop
      btop
    ];
  };
}
