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

    # Compositor Picom ultra-leve para o MacBook Pro 4,1 (Intel Core 2 Duo / GeForce 8600M GT)
    desktop.bspwm.picom = {
      enable = true;
      backend = "xrender"; # CPU/GPU ultra-fria: sem shaders pesados na GPU legada
      animations.enable = false; # Desativa animações complexas para resposta instantânea
      blur.enable = false; # Sem blur (dual_kawase), zerando o uso de VRAM
      useDamage = true; # Repinta apenas as regiões modificadas da tela
    };

    # Teclado Apple: swap_opt_cmd=0 no kernel já define Command = Super (Mod4) e Option = Alt (Mod1) nativamente

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
