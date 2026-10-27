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

  activeBrowsers = if cfg.browsers != [ ] then cfg.browsers else autoDetectedBrowsers;

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

  config = lib.mkMerge [
    # Hook de ativação executado antes de checkLinkTargets:
    # Remove qualquer arquivo órfão ou inativo em ~/.config/psd/browsers/ ao trocar de navegador ou desativar o PSD,
    # garantindo que o diretório contenha estritamente os navegadores ativos e evitando conflitos de links no switch.
    {
      home.activation.cleanPsdBrowsers = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        psd_browsers_dir="$HOME/.config/psd/browsers"
        if [ -d "$psd_browsers_dir" ]; then
          ${
            if cfg.enable then
              ''
                active_browsers=(${builtins.concatStringsSep " " (map (b: lib.escapeShellArg b) activeBrowsers)})

                for file in "$psd_browsers_dir"/*; do
                  [ -e "$file" ] || [ -L "$file" ] || continue
                  browser_name="$(basename "$file")"

                  is_active=0
                  for active in "''${active_browsers[@]}"; do
                    if [ "$browser_name" = "$active" ]; then
                      is_active=1
                      break
                    fi
                  done

                  # Se o arquivo não pertence a um navegador ativo na configuração atual, remove
                  if [ "$is_active" -eq 0 ]; then
                    $DRY_RUN_CMD rm -rf "$file"
                  # Se pertence ao navegador ativo mas é um arquivo comum antigo (não symlink do nix)
                  # ou um symlink quebrado, remove para que o Home Manager crie o symlink limpo
                  elif [ -f "$file" ] && [ ! -L "$file" ]; then
                    $DRY_RUN_CMD rm -f "$file"
                  elif [ -L "$file" ] && [ ! -e "$file" ]; then
                    $DRY_RUN_CMD rm -f "$file"
                  fi
                done
              ''
            else
              ''
                $DRY_RUN_CMD rm -rf "$psd_browsers_dir"
              ''
          }
          if [ -d "$psd_browsers_dir" ] && [ -z "$($DRY_RUN_CMD ls -A "$psd_browsers_dir" 2>/dev/null)" ]; then
            $DRY_RUN_CMD rmdir "$psd_browsers_dir" 2>/dev/null || true
          fi
        fi
      '';
    }

    (lib.mkIf cfg.enable {
      # Garante que os scripts de descoberta de navegadores estejam presentes em ~/.config/psd/browsers/
      # apenas para os navegadores de fato ativos/habilitados
      xdg.configFile = lib.mkMerge [
        (lib.mkIf (builtins.elem "librewolf" activeBrowsers) {
          "psd/browsers/librewolf".text = ''
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
        })

        (lib.mkIf (builtins.elem "floorp" activeBrowsers) {
          "psd/browsers/floorp".text = ''
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
        })

        (lib.mkIf (builtins.elem "brave" activeBrowsers) {
          "psd/browsers/brave".text = ''
            if [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/BraveSoftware/Brave-Browser" ]]; then
                DIRArr[0]="''${XDG_CONFIG_HOME:-$HOME/.config}/BraveSoftware/Brave-Browser"
                PSNAME="(brave|\.brave-wra.*)"
            fi
            check_suffix=1
          '';
        })

        (lib.mkIf (builtins.elem "microsoft-edge" activeBrowsers) {
          "psd/browsers/microsoft-edge".text = ''
            if [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge" ]]; then
                DIRArr[0]="''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge"
                PSNAME="(msedge|microsoft-edge|\.msedge-wra.*|\.microsoft-edge-wra.*)"
            elif [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge-dev" ]]; then
                DIRArr[0]="''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge-dev"
                PSNAME="(msedge|microsoft-edge|\.msedge-wra.*|\.microsoft-edge-wra.*)"
            fi
            check_suffix=1
          '';
        })
      ];

      # Delega para o módulo oficial nativo do Home Manager (services.psd)
      services.psd = {
        enable = true;
        package = cfg.package;
        browsers = activeBrowsers;
        resyncTimer = cfg.resyncTimer;
        useBackup = cfg.useBackup;
        backupLimit = cfg.backupLimit;
      };

      # Reinicia o serviço no switch se estiver em execução para recarregar o novo navegador/config
      home.activation.reloadPsd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if systemctl --user is-active --quiet psd.service 2>/dev/null; then
          $DRY_RUN_CMD systemctl --user restart psd.service psd-resync.timer 2>/dev/null || true
        fi
      '';
    })
  ];
}
