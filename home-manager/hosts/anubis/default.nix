{
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
          chromium = {
            enable = true;
            version = "vivaldi";
          };
        };
        editors = {
          antigravity.enable = true;
        };
        multimedia = {
          mpv.enable = true;
        };
        terminal = {
          enable = true;
          name = "alacritty";
        };
      };
    };

    # Extensão Continue (Chat + Autocomplete com Gemini)
    # programs.vscode.profiles.default.extensions =
    #   lib.mkIf config.system.programs.editors.vscode.enable
    #     (
    #       pkgs.nix4vscode.forVscode [
    #         "Continue.continue"
    #       ]
    #     );

    # Compositor Picom leve
    desktop.bspwm.picom = {
      enable = true;
      backend = "xrender";
      animations.enable = false;
      blur.enable = false;
      useDamage = true;
    };

    # Fuso horário America/Sao_Paulo para o Anubis (relógio da Polybar e sessão)
    home.sessionVariables = {
      TZ = "America/Sao_Paulo";
    };

    desktop.bspwm.extraConfig = ''
      export TZ="America/Sao_Paulo"
    '';

    # Teclado Mac com dead keys para acentos PT-BR (é, ã, ç)
    home.keyboard = {
      layout = "us";
      variant = "intl";
      model = "apple";
    };

    # Configuração declarativa de monitor e resolução (MacBook Air 11.6" - LP116WH4-TJA3)
    desktop.monitors = [
      {
        name = "eDP-1";
        width = 1366;
        height = 768;
        refresh = 60;
        primary = true;
      }
    ];

    home.packages = with pkgs; [
      direnv
      nix-direnv
      nil
      git
      nh
      duf
      fzf
      ripgrep
      htop
    ];

    programs = {
      antigravity-cli = {
        enable = true;
      };
    };
  };
}
