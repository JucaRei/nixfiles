{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    concatStringsSep
    ;

  cfg = config.system.programs.chat.discord;

  # Paletas e Definições de Temas
  themeDefinitions = {
    "catppuccin-frappe" = {
      name = "Catppuccin Frappé";
      fileName = "catppuccin-frappe.theme.css";
      css = ''
        /**
         * @name Catppuccin Frappé
         * @author Catppuccin
         * @version 1.0.0
         * @description Soothing pastel theme for Discord (Frappé flavor)
         * @source https://github.com/catppuccin/discord
        **/
        @import url("https://catppuccin.github.io/discord/dist/catppuccin-frappe.theme.css");

        :root {
          --theme-name: "Catppuccin Frappé";
          --background-primary: #303446;
          --background-secondary: #292c3c;
          --background-secondary-alt: #232634;
          --background-tertiary: #232634;
          --background-accent: #414559;
          --background-floating: #232634;
          --channeltextarea-background: #414559;
          --text-normal: #c6d0f5;
          --text-muted: #a5adce;
          --text-link: #8caaee;
          --interactive-normal: #b5bfe2;
          --interactive-hover: #c6d0f5;
          --interactive-active: #ffffff;
          --interactive-muted: #626880;
          --brand-experiment: #8caaee;
          --header-primary: #c6d0f5;
          --header-secondary: #b5bfe2;
        }
      '';
    };

    "catppuccin-mocha" = {
      name = "Catppuccin Mocha";
      fileName = "catppuccin-mocha.theme.css";
      css = ''
        /**
         * @name Catppuccin Mocha
         * @author Catppuccin
         * @version 1.0.0
         * @description Soothing pastel theme for Discord (Mocha flavor)
         * @source https://github.com/catppuccin/discord
        **/
        @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css");

        :root {
          --theme-name: "Catppuccin Mocha";
          --background-primary: #1e1e2e;
          --background-secondary: #181825;
          --background-secondary-alt: #11111b;
          --background-tertiary: #11111b;
          --background-accent: #313244;
          --background-floating: #11111b;
          --channeltextarea-background: #313244;
          --text-normal: #cdd6f4;
          --text-muted: #a6adc8;
          --text-link: #89b4fa;
          --interactive-normal: #bac2de;
          --interactive-hover: #cdd6f4;
          --interactive-active: #ffffff;
          --interactive-muted: #585b70;
          --brand-experiment: #89b4fa;
          --header-primary: #cdd6f4;
          --header-secondary: #bac2de;
        }
      '';
    };

    "doom" = {
      name = "Doom One Dark";
      fileName = "doom.theme.css";
      css = ''
        /**
         * @name Doom One Dark
         * @author Doom Emacs / nixfiles
         * @version 1.0.0
         * @description Doom One Dark palette for Discord
        **/

        :root {
          --theme-name: "Doom One Dark";

          --background-primary: #282c34;
          --background-secondary: #21242b;
          --background-secondary-alt: #1b1d23;
          --background-tertiary: #1b1d23;
          --background-accent: #50536b;
          --background-floating: #1b1d23;

          --channeltextarea-background: #21242b;

          --text-normal: #dfdfdf;
          --text-muted: #abb2bf;
          --text-link: #6eaafb;
          --text-positive: #95be65;
          --text-warning: #ecbe7b;
          --text-danger: #ff6c6b;

          --interactive-normal: #abb2bf;
          --interactive-hover: #dfdfdf;
          --interactive-active: #ffffff;
          --interactive-muted: #50536b;

          --brand-experiment: #6eaafb;
          --brand-experiment-560: #2257a0;

          --header-primary: #dfdfdf;
          --header-secondary: #b2b2b2;

          --scrollbar-auto-thumb: #50536b;
          --scrollbar-auto-track: #21242b;
        }
      '';
    };

    "dracula" = {
      name = "Dracula";
      fileName = "dracula.theme.css";
      css = ''
        /**
         * @name Dracula
         * @author Dracula Theme / nixfiles
         * @version 1.0.0
         * @description Dracula theme for Discord
         * @source https://github.com/dracula/discord
        **/
        @import url("https://raw.githubusercontent.com/dracula/discord/master/dist/dracula.theme.css");

        :root {
          --theme-name: "Dracula";

          --background-primary: #282936;
          --background-secondary: #3a3c4e;
          --background-secondary-alt: #1e1f29;
          --background-tertiary: #1e1f29;
          --background-accent: #4d4f68;
          --background-floating: #1e1f29;

          --channeltextarea-background: #3a3c4e;

          --text-normal: #e9e9f4;
          --text-muted: #626483;
          --text-link: #62d6e8;
          --text-positive: #00f769;
          --text-warning: #ebff87;
          --text-danger: #ea51b2;

          --interactive-normal: #e9e9f4;
          --interactive-hover: #f7f7fb;
          --interactive-active: #ffffff;
          --interactive-muted: #626483;

          --brand-experiment: #b45bcf;
          --brand-experiment-560: #626483;

          --header-primary: #f7f7fb;
          --header-secondary: #e9e9f4;

          --scrollbar-auto-thumb: #4d4f68;
          --scrollbar-auto-track: #282936;
        }
      '';
    };
  };

  activeTheme = themeDefinitions.${cfg.theme.scheme} or themeDefinitions."catppuccin-frappe";

  discordPkg = pkgs.discord.override {
    withOpenASAR = cfg.openasar.enable;
    withVencord = cfg.vencord.enable;
    commandLineArgs = concatStringsSep " " cfg.extraCommandLineArgs;
  };
in
{
  options.system.programs.chat.discord = {
    enable = mkEnableOption "Discord client with performance tweaks and custom themes (Catppuccin Frappé, Doom, Dracula)";

    client = mkOption {
      type = types.enum [
        "discord"
        "vesktop"
        "both"
      ];
      default = "discord";
      description = "Discord client variant to install (discord = official + OpenASAR/Vencord, vesktop = modern Wayland app).";
    };

    vencord = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Inject Vencord into Discord for plugins, themes and screen audio on Linux.";
      };
    };

    openasar = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Use OpenASAR replacement for faster boot and reduced memory usage.";
      };
    };

    theme = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Deploy and enable selected theme for Discord/Vesktop/Vencord.";
      };

      scheme = mkOption {
        type = types.enum [
          "catppuccin-frappe"
          "catppuccin-mocha"
          "doom"
          "dracula"
        ];
        default = "catppuccin-frappe";
        description = "Active color theme scheme for Discord.";
      };
    };

    extraCommandLineArgs = mkOption {
      type = types.listOf types.str;
      default = [
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandWindowDecorations"
      ];
      description = "Extra command line flags passed to Discord Electron.";
    };
  };

  config = mkIf cfg.enable {
    # 1. Instalação dos pacotes selecionados
    home.packages =
      (lib.optional (cfg.client == "discord" || cfg.client == "both") discordPkg)
      ++ (lib.optional (cfg.client == "vesktop" || cfg.client == "both") pkgs.vesktop);

    # 2. Implantação de todos os arquivos de tema CSS (para troca rápida nas configurações do Vencord/BetterDiscord)
    xdg.configFile = mkIf cfg.theme.enable (
      lib.mkMerge (
        lib.mapAttrsToList (
          _id: theme: {
            "Vencord/themes/${theme.fileName}".text = theme.css;
            "vesktop/themes/${theme.fileName}".text = theme.css;
            "BetterDiscord/themes/${theme.fileName}".text = theme.css;
          }
        ) themeDefinitions
        ++ [
          # Symlink para o tema corrente selecionado
          {
            "Vencord/themes/current.theme.css".text = activeTheme.css;
            "vesktop/themes/current.theme.css".text = activeTheme.css;
            "BetterDiscord/themes/current.theme.css".text = activeTheme.css;
          }
        ]
      )
    );

    # 3. Inicialização automática não-destrutiva de configurações do Vencord / Vesktop
    # Ativa o tema selecionado por padrão e plugins de conveniência sem bloquear o arquivo como read-only
    home.activation.initDiscordSettings = mkIf cfg.theme.enable (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        for dir in "$HOME/.config/Vencord/settings" "$HOME/.config/vesktop/settings"; do
          mkdir -p "$dir"
          settings_file="$dir/settings.json"
          if [ ! -f "$settings_file" ]; then
            cat > "$settings_file" << 'EOF'
{
  "notifyAboutUpdates": false,
  "autoUpdate": false,
  "autoUpdateNotification": false,
  "useQuickCss": true,
  "themeLinks": [],
  "enabledThemes": ["${activeTheme.fileName}"],
  "enableReactDevtools": false,
  "plugins": {
    "WebContextMenus": { "enabled": true },
    "VoiceChatDoubleClick": { "enabled": true },
    "Translate": { "enabled": true },
    "ShowConnections": { "enabled": true },
    "PlatformIndicators": { "enabled": true },
    "OpenInApp": { "enabled": true },
    "ImageZoom": { "enabled": true },
    "FixSpotifyEmbeds": { "enabled": true },
    "CopyUserURLs": { "enabled": true },
    "BetterRoleDot": { "enabled": true },
    "BetterGifPicker": { "enabled": true },
    "AnonymiseFileNames": { "enabled": true }
  }
}
EOF
          fi
        done

        # Configuração inicial do OpenASAR (se habilitado)
        ${lib.optionalString cfg.openasar.enable ''
          discord_config_dir="$HOME/.config/discord"
          mkdir -p "$discord_config_dir"
          openasar_file="$discord_config_dir/settings.json"
          if [ ! -f "$openasar_file" ]; then
            cat > "$openasar_file" << 'EOF'
{
  "openasar": {
    "setup": true,
    "quickstart": true
  }
}
EOF
          fi
        ''}
      ''
    );
  };
}
