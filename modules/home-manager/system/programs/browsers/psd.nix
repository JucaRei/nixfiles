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
    # Garante que os scripts de descoberta de navegadores estejam presentes em ~/.config/psd/browsers/
    xdg.configFile."psd/browsers/librewolf".text = ''
      librewolf_dir=""
      if [[ -d "$HOME/.librewolf" ]]; then
          librewolf_dir="$HOME/.librewolf"
      elif [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/librewolf" ]]; then
          librewolf_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/librewolf"
      fi

      index=0
      PSNAME="(librewolf|\.librewolf-wra.*)"
      if [[ -n "$librewolf_dir" && -f "$librewolf_dir/profiles.ini" ]]; then
          while read -r profileItem; do
              if [[ $(echo "$profileItem" | cut -c1) = "/" ]]; then
                  DIRArr[$index]="$profileItem"
              else
                  DIRArr[$index]="$librewolf_dir/$profileItem"
              fi
              (( index=index+1 ))
          done < <(grep -i '^path=' "$librewolf_dir/profiles.ini" 2>/dev/null | sed -e 's/^[Pp]ath=//' | tr -d '\r')
      fi
      if [[ ''${#DIRArr[@]} -eq 0 && -n "$librewolf_dir" ]]; then
          for prof in "$librewolf_dir"/*.default*; do
              if [[ -d "$prof" ]]; then
                  DIRArr[$index]="$prof"
                  (( index=index+1 ))
              fi
          done
      fi
      check_suffix=1
    '';

    xdg.configFile."psd/browsers/floorp".text = ''
      floorp_dir=""
      if [[ -d "$HOME/.floorp" ]]; then
          floorp_dir="$HOME/.floorp"
      elif [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/floorp" ]]; then
          floorp_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/floorp"
      fi

      index=0
      PSNAME="(floorp|\.floorp-wra.*)"
      if [[ -n "$floorp_dir" && -f "$floorp_dir/profiles.ini" ]]; then
          while read -r profileItem; do
              if [[ $(echo "$profileItem" | cut -c1) = "/" ]]; then
                  DIRArr[$index]="$profileItem"
              else
                  DIRArr[$index]="$floorp_dir/$profileItem"
              fi
              (( index=index+1 ))
          done < <(grep -i '^path=' "$floorp_dir/profiles.ini" 2>/dev/null | sed -e 's/^[Pp]ath=//' | tr -d '\r')
      fi
      if [[ ''${#DIRArr[@]} -eq 0 && -n "$floorp_dir" ]]; then
          for prof in "$floorp_dir"/*.default*; do
              if [[ -d "$prof" ]]; then
                  DIRArr[$index]="$prof"
                  (( index=index+1 ))
              fi
          done
      fi
      check_suffix=1
    '';

    xdg.configFile."psd/browsers/brave".text = ''
      if [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/BraveSoftware/Brave-Browser" ]]; then
          DIRArr[0]="''${XDG_CONFIG_HOME:-$HOME/.config}/BraveSoftware/Brave-Browser"
          PSNAME="(brave|\.brave-wra.*)"
      fi
      check_suffix=1
    '';

    xdg.configFile."psd/browsers/microsoft-edge".text = ''
      if [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge" ]]; then
          DIRArr[0]="''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge"
          PSNAME="(msedge|microsoft-edge|\.msedge-wra.*|\.microsoft-edge-wra.*)"
      elif [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge-dev" ]]; then
          DIRArr[0]="''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge-dev"
          PSNAME="(msedge|microsoft-edge|\.msedge-wra.*|\.microsoft-edge-wra.*)"
      fi
      check_suffix=1
    '';

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
