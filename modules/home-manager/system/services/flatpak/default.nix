{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.system.services.flatpak;
in
{
  options.system.services.flatpak = {
    enable = mkEnableOption "Gerenciamento declarativo de Flatpaks via nix-flatpak no Home Manager";

    packages =
      lib.my.mkListOf (lib.types.either lib.types.str (lib.types.attrsOf lib.types.anything)) [ ]
        ''
          Lista declarativa de pacotes Flatpak a serem instalados no host.
          Suporta strings com App ID ou attribute sets configurando appId, origin, commit, flatpakref ou bundle.
        '';

    remotes = lib.my.mkListOf (lib.types.attrsOf lib.types.anything) [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ] "Lista de repositórios remotos do Flatpak (Flathub configurado por padrão).";

    update = {
      onActivation = lib.my.mkBool false "Se verdadeiro, atualiza os Flatpaks a cada home-manager switch (falso por padrão para manter o switch rápido).";

      auto = {
        enable = lib.my.mkBool false "Habilitar atualizações automáticas periódicas em background via systemd user timer.";

        onCalendar = lib.my.mkStr "weekly" "Expressão OnCalendar do systemd para o timer de auto-atualização (ex: 'weekly', 'daily').";
      };
    };

    overrides =
      lib.my.mkOpt (lib.types.attrsOf lib.types.anything) { }
        "Permissões e overrides declarativos por aplicativo Flatpak (equivalente ao Flatseal via código).";

    uninstallUnmanaged = lib.my.mkBool false "Se verdadeiro, remove Flatpaks instalados manualmente fora do Nix (convergência estrita).";
  };

  config = mkIf cfg.enable {
    # Integração com o módulo upstream nix-flatpak
    services.flatpak = {
      enable = true;
      inherit (cfg) packages;
      inherit (cfg) remotes;
      inherit (cfg) uninstallUnmanaged;
      update = {
        onActivation = cfg.update.onActivation;
        auto = {
          enable = cfg.update.auto.enable;
          onCalendar = cfg.update.auto.onCalendar;
        };
      };
      inherit (cfg) overrides;
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
