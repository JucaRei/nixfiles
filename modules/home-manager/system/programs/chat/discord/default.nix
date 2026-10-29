{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    concatStringsSep
    ;

  cfg = config.system.programs.chat.discord;
  c = config.desktop.theme.colors;

  # Tema dinâmico gerado exclusivamente a partir de config.desktop.theme.colors
  desktopThemeCss = ''
    /**
     * @name Desktop Theme (${config.desktop.theme.name})
     * @author nixfiles
     * @version 1.0.0
     * @description Dynamic theme based on config.desktop.theme
    **/
    :root {
      --theme-name: "${config.desktop.theme.name}";
      --background-primary: ${c.bg};
      --background-secondary: ${c.bgAlt};
      --background-secondary-alt: ${c.bgDark};
      --background-tertiary: ${c.bgDark};
      --background-accent: ${c.surfaceAlt};
      --background-floating: ${c.bgDark};
      --channeltextarea-background: ${c.surface};
      --text-normal: ${c.fg};
      --text-muted: ${c.fgMuted};
      --text-link: ${c.accent};
      --text-positive: ${c.green};
      --text-warning: ${c.yellow};
      --text-danger: ${c.red};
      --interactive-normal: ${c.fgMuted};
      --interactive-hover: ${c.fg};
      --interactive-active: ${c.fg};
      --interactive-muted: ${c.border};
      --brand-experiment: ${c.accent};
      --header-primary: ${c.fg};
      --header-secondary: ${c.fgMuted};
    }
  '';

  discordPkg = pkgs.discord.override {
    withOpenASAR = cfg.openasar.enable;
    withVencord = cfg.vencord.enable;
    commandLineArgs = concatStringsSep " " cfg.extraCommandLineArgs;
  };
in
{
  options.system.programs.chat.discord = {
    enable = mkEnableOption "Discord client with performance tweaks and dynamic desktop theme";

    client =
      lib.my.mkEnum
        [
          "discord"
          "vesktop"
          "both"
        ]
        "discord"
        "Discord client variant to install (discord = official + OpenASAR/Vencord, vesktop = modern Wayland app).";

    vencord = {
      enable = lib.my.mkBool true "Inject Vencord into Discord for plugins, themes and screen audio on Linux.";
    };

    openasar = {
      enable = lib.my.mkBool true "Use OpenASAR replacement for faster boot and reduced memory usage.";
    };

    theme = {
      enable = lib.my.mkBool true "Deploy and enable dynamic theme for Discord/Vesktop/Vencord.";
    };

    installPackage = lib.my.mkBool true ''
      Se deve instalar o executável do Discord/Vesktop via Nix.
      Se false, apenas os arquivos de temas (.theme.css) e configurações serão gerenciados, utilizando a versão nativa do sistema hospedeiro (ex: .deb ou flatpak).
    '';

    useSystemPackage = lib.my.mkBool false ''
      Atalho conveniente: quando true, equivale a installPackage = false.
      Permite carregar apenas os temas e configurações utilizando o Discord nativo da distro.
    '';

    useSystemPackages = lib.my.mkBool false "Alias para useSystemPackage.";

    extraCommandLineArgs = lib.my.mkListOf lib.types.str [
      "--ozone-platform-hint=auto"
      "--enable-features=WaylandWindowDecorations"
    ] "Extra command line flags passed to Discord Electron.";
  };

  config = mkIf cfg.enable {
    # 1. Instalação dos pacotes selecionados (apenas se shouldInstall = true)
    home.packages = mkIf (cfg.installPackage && !cfg.useSystemPackage && !cfg.useSystemPackages) (
      (lib.optional (cfg.client == "discord" || cfg.client == "both") (nixGLWrapper discordPkg))
      ++ (lib.optional (cfg.client == "vesktop" || cfg.client == "both") (nixGLWrapper pkgs.vesktop))
    );

    # 2. Implantação do tema CSS dinâmico
    xdg.configFile = mkIf cfg.theme.enable {
      "Vencord/themes/desktop-theme.theme.css".text = desktopThemeCss;
      "vesktop/themes/desktop-theme.theme.css".text = desktopThemeCss;
      "BetterDiscord/themes/desktop-theme.theme.css".text = desktopThemeCss;
      "Vencord/themes/current.theme.css".text = desktopThemeCss;
      "vesktop/themes/current.theme.css".text = desktopThemeCss;
      "BetterDiscord/themes/current.theme.css".text = desktopThemeCss;
    };

    # 3. Inicialização automática não-destrutiva de configurações do Vencord / Vesktop
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
          "enabledThemes": ["desktop-theme.theme.css"],
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
