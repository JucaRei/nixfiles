{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.programs.browsers.psd;
  cfgBrowsers = config.system.programs.browsers;

  # Detecta automaticamente navegadores configurados caso a lista não seja explicitada
  autoDetectedBrowsers =
    (lib.optional cfgBrowsers.firefox.enable (
      let
        ver = cfgBrowsers.firefox.version or "firefox";
      in
      if ver == "librewolf" then
        "librewolf"
      else if ver == "floorp" then
        "floorp"
      else
        "firefox"
    ))
    ++ (lib.optional cfgBrowsers.chromium.enable (
      let
        ver = cfgBrowsers.chromium.version or "chromium";
      in
      if ver == "brave" then
        "brave"
      else if ver == "google-chrome" then
        "google-chrome"
      else if ver == "vivaldi" then
        "vivaldi"
      else if ver == "edge" then
        "microsoft-edge"
      else
        "chromium"
    ));

  activeBrowsers =
    if cfg.browsers != [ ] then
      cfg.browsers
    else
      autoDetectedBrowsers;

  anyBrowserEnabled = cfgBrowsers.firefox.enable || cfgBrowsers.chromium.enable;
in
{
  options.system.programs.browsers.psd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = anyBrowserEnabled;
      description = ''
        Habilitar Profile-Sync-Daemon (psd) via o módulo oficial services.psd do Home Manager.
        Por padrão é true se algum navegador estiver habilitado (Firefox/LibreWolf/Floorp ou Chromium/Brave/etc).
      '';
    };

    resyncTimer = lib.mkOption {
      type = lib.types.str;
      default = "1h";
      example = "30min";
      description = "Intervalo de ressincronização automática dos perfis da RAM para o disco.";
    };

    browsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "librewolf"
        "brave"
      ];
      description = ''
        Lista explícita de navegadores a serem gerenciados pelo PSD.
        Se vazia, detecta automaticamente os navegadores configurados ou disponíveis no sistema.
      '';
    };

    useBackup = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Habilitar backups automáticos de segurança para recuperação em caso de travamentos ou falhas de energia.
      '';
    };

    backupLimit = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = ''
        Número máximo de snapshots de recuperação a manter no disco.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.profile-sync-daemon;
      description = "Pacote do profile-sync-daemon utilizado.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Delega para o módulo oficial nativo do Home Manager (services.psd)
    services.psd = {
      enable = true;
      package = cfg.package;
      browsers = activeBrowsers;
      resyncTimer = cfg.resyncTimer;
      useBackup = cfg.useBackup;
      backupLimit = cfg.backupLimit;
    };
  };
}
