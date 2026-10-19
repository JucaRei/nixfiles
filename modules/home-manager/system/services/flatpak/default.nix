{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.system.services.flatpak;
in
{
  options.system.services.flatpak = {
    enable = mkEnableOption "Gerenciamento declarativo de Flatpaks via nix-flatpak no Home Manager";

    packages = mkOption {
      type = types.listOf (types.either types.str (types.attrsOf types.anything));
      default = [ ];
      example = [
        "com.spotify.Client"
        "org.mozilla.firefox"
        {
          appId = "im.riot.Riot";
          origin = "flathub";
        }
        {
          appId = "org.libretro.RetroArch";
          commit = "e6be1463c90ba15e8f023e994dfc6fb0567e40730d8eb254ae356205391d0dc5";
        }
        {
          appId = "io.github.karem505.whatRust";
          sha256 = "<hash>";
          bundle = "<path-or-fetchurl>";
        }
      ];
      description = ''
        Lista declarativa de pacotes Flatpak a serem instalados no host.
        Suporta strings com App ID ou attribute sets configurando appId, origin, commit, flatpakref ou bundle.
      '';
    };

    remotes = mkOption {
      type = types.listOf (types.attrsOf types.anything);
      default = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      description = "Lista de repositórios remotos do Flatpak (Flathub configurado por padrão).";
    };

    update = {
      onActivation = mkOption {
        type = types.bool;
        default = false;
        description = "Se verdadeiro, atualiza os Flatpaks a cada home-manager switch (falso por padrão para manter o switch rápido).";
      };

      auto = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Habilitar atualizações automáticas periódicas em background via systemd user timer.";
        };

        onCalendar = mkOption {
          type = types.str;
          default = "weekly";
          description = "Expressão OnCalendar do systemd para o timer de auto-atualização (ex: 'weekly', 'daily').";
        };
      };
    };

    overrides = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      example = {
        global = {
          Context.sockets = [
            "wayland"
            "!x11"
          ];
        };
      };
      description = "Permissões e overrides declarativos por aplicativo Flatpak (equivalente ao Flatseal via código).";
    };

    uninstallUnmanaged = mkOption {
      type = types.bool;
      default = false;
      description = "Se verdadeiro, remove Flatpaks instalados manualmente fora do Nix (convergência estrita).";
    };
  };

  config = mkIf cfg.enable {
    # Integração com o módulo upstream nix-flatpak
    services.flatpak = {
      enable = true;
      packages = cfg.packages;
      remotes = cfg.remotes;
      uninstallUnmanaged = cfg.uninstallUnmanaged;
      update = {
        onActivation = cfg.update.onActivation;
        auto = {
          enable = cfg.update.auto.enable;
          onCalendar = cfg.update.auto.onCalendar;
        };
      };
      overrides = cfg.overrides;
    };

    # Exporta caminhos para que os launchers (.desktop) e binários dos Flatpaks sejam detectados pelos menus e WMs
    xdg.systemDirs.data = [
      "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
      "/var/lib/flatpak/exports/share"
    ];

    home.sessionPath = [
      "${config.home.homeDirectory}/.local/share/flatpak/exports/bin"
      "/var/lib/flatpak/exports/bin"
    ];
  };
}
