{
  pkgs,
  ...
}:
{
  config = {
    system.programs = {
      browsers = {
        chromium = {
          enable = true;
          version = "vivaldi";
        };
        # Desativa Profile-Sync-Daemon no Anubis para preservar a RAM de 2GB e evitar estouro de /run/user/1000
        psd.enable = false;
      };
      multimedia.mpv.profile = "low-ram";
    };

    home = {
      # Teclado Mac com dead keys para acentos PT-BR (é, ã, ç)
      keyboard = {
        layout = "us";
        variant = "intl";
        model = "apple";
      };

      packages = [
        pkgs.direnv
        pkgs.nix-direnv
        pkgs.nil
        pkgs.nh
        pkgs.libva-utils
        pkgs.intel-gpu-tools
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
          pre_action_fade_seconds = 0.0;
          behavior = {
            lock = {
              timeout = 300;
              action = "lock";
              enabled = true;
            };
            screen-off = {
              timeout = 450;
              action = "command";
              command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 0%";
              resume_command = "${pkgs.brightnessctl}/bin/brightnessctl -r";
              enabled = true;
            };
            suspend = {
              timeout = 900;
              action = "suspend";
              enabled = true;
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

    programs.antigravity-cli.enable = true;
  };
}
