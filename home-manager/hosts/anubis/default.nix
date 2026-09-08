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

    # Teclado Mac com dead keys para acentos PT-BR (é, ã, ç)
    home.keyboard = {
      layout = "us";
      variant = "intl";
      model = "apple";
    };

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
  };
}
