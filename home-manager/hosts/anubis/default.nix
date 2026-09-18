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
    # desktop.

    home = {
      # Fuso horário America/Sao_Paulo para o Anubis (relógio da Polybar e sessão)
      sessionVariables = {
        TZ = "America/Sao_Paulo";
      };

      # Teclado Mac com dead keys para acentos PT-BR (é, ã, ç)
      keyboard = {
        layout = "us";
        variant = "intl";
        model = "apple";
      };

      packages = with pkgs; [
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

    desktop = {

      wayland.noctalia.settings = {
        idle = {
          behavior_order = [
            "lock"
            "screen-off"
            "suspend"
          ];
          pre_action_fade_seconds = 30.0;
          bahavior = {
            lock = {
              timeout = 300;
              action = "lock";
              enabled = true;
            };
            screen-off = {
              timeout = 450;
              action = "screen_off";
              enabled = true;
            };
            suspend = {
              timeout = 900;
              action = "suspend";
              enabled = true;
            };
            custom = {
              timeout = 200;
              action = "command";
              command = "notify-send 'Idle' 'Going idle'";
              resume_command = "notify-send 'Idle' 'Back from idle'";
            };
          };
        };
        audio = {
          enable_overdrive = true;
          enable_sounds = false;
          sound_volume = 0.5;
          volume_change_sound = "";
          notification_sound = "";
        };
        location = {
          auto_locate = true;
          address = "São Paulo, Brazil";
          latitude = -23.6293;
          longitude = -46.6351;
        };
      };

      # bspwm.extraConfig = ''
      #   export TZ="America/Sao_Paulo"
      # '';

      # bspwm.picom = {
      #   enable = true;
      #   backend = "xrender";
      #   animations.enable = false;
      #   blur.enable = false;
      #   useDamage = true;
      # };

      # Configuração declarativa de monitor e resolução (MacBook Air 11.6" - LP116WH4-TJA3)
      monitors = [
        {
          name = "eDP-1";
          width = 1366;
          height = 768;
          refresh = 60;
          primary = true;
        }
      ];
    };

    programs = {
      antigravity-cli = {
        enable = true;
      };
    };
  };
}
