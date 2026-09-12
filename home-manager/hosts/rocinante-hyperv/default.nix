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
          # vscode = {
          #   enable = true;
          #   enableConfigurableSettings = true;
          # };
          antigravity = {
            enable = true;
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

    # Ativa compositor picom no Hyper-V usando xrender (evita falha de falta de GL visual em VM)
    desktop.bspwm = {
      picom = {
        enable = true;
        backend = "xrender";
        animations.enable = false;
      };
      # packages.extraPackages = with pkgs; [ libreoffice-qt ];
    };

    programs = {

      antigravity-cli = {
        enable = true;
      };

      # Adiciona a extensão Continue (Chat + Autocomplete com Gemini) no VS Code do Hyper-V
      vscode.profiles.default.extensions = lib.mkIf config.system.programs.editors.vscode.enable (
        pkgs.nix4vscode.forVscode [
          "Continue.continue"
        ]
      );
    };

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
