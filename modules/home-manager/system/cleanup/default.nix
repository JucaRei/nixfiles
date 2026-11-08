{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mkIf
    optionalString
    ;

  cfg = config.system.cleanup;

  # Registro declarativo de aplicações conhecidas extraído para _known-apps.nix
  knownApps = import ./_known-apps.nix { inherit config; };

  # Filtra apenas aplicações que estão desativadas ou removidas
  inactiveApps = builtins.filter (app: !app.enabled) knownApps;

  # Constrói o bloco de limpeza estática declarativa
  declarativeCleanupCommands = concatStringsSep "\n" (
    map (app: ''
      # [${app.name}] - Aplicação desativada ou removida
      ${concatStringsSep "\n" (
        map (p: ''
          for target in ${p}; do
            if [ -e "$target" ] || [ -L "$target" ]; then
              remove_path "$target" "${app.name} (config)"
            fi
          done
        '') app.configs
      )}
      ${optionalString cfg.cleanCaches (
        concatStringsSep "\n" (
          map (p: ''
            for target in ${p}; do
              if [ -e "$target" ] || [ -L "$target" ]; then
                remove_path "$target" "${app.name} (cache)"
              fi
            done
          '') app.caches
        )
      )}
      ${optionalString cfg.cleanData (
        concatStringsSep "\n" (
          map (p: ''
            for target in ${p}; do
              if [ -e "$target" ] || [ -L "$target" ]; then
                remove_path "$target" "${app.name} (local share)"
              fi
            done
          '') app.data
        )
      )}
      ${concatStringsSep "\n" (
        map (p: ''
          for target in ${p}; do
            if [ -e "$target" ] || [ -L "$target" ]; then
              remove_path "$target" "${app.name} (desktop entry)"
            fi
          done
        '') app.desktops
      )}
    '') inactiveApps
  );

  # Script executável e despachante de limpeza de órfãos
  cleanupScript = pkgs.writeShellScriptBin "clean-orphaned-configs" ''
    set -euo pipefail

    DRY_RUN=0
    VERBOSE=0
    OLD_GEN=""
    NEW_GEN=""

    while [ $# -gt 0 ]; do
      case "$1" in
        --dry-run|-n)
          DRY_RUN=1
          shift
          ;;
        --verbose|-v)
          VERBOSE=1
          shift
          ;;
        --old-gen)
          OLD_GEN="''${2:-}"
          shift 2 || shift 1
          ;;
        --new-gen)
          NEW_GEN="''${2:-}"
          shift 2 || shift 1
          ;;
        *)
          shift
          ;;
      esac
    done

    # Respeita a variável DRY_RUN_CMD fornecida pelo Home Manager
    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      DRY_RUN=1
    fi

    # Diretórios protegidos essenciais que NUNCA devem ser deletados dinamicamente
    PROTECTED_CONFIGS=(
      "dconf"
      "gtk-3.0"
      "gtk-4.0"
      "fontconfig"
      "systemd"
      "environment.d"
      "pulse"
      "home-manager"
      "nix"
      "sops"
      "autostart"
      "git"
      "errors"
      "bspwm"
      "sxhkd"
      "polybar"
      "picom"
      "rofi"
      "dunst"
      "hypr"
      "mango"
      "waybar"
      "zsh"
      "bash"
      "fish"
      "starship"
      "starship.toml"
      "mimeapps.list"
      "user-dirs.dirs"
      "user-dirs.conf"
      "user-tmpfiles.d"
    )

    is_protected() {
      local name="$1"
      for p in "''${PROTECTED_CONFIGS[@]}"; do
        if [ "$name" = "$p" ]; then
          return 0
        fi
      done
      return 1
    }

    remove_path() {
      local path="$1"
      local reason="$2"

      # Se for um link simbólico que aponta para o Nix store gerenciado ativamente, não remove
      if [ -L "$path" ] && [ -e "$path" ]; then
        local target
        target="$(readlink -f "$path" 2>/dev/null || true)"
        if [[ "$target" =~ /nix/store/.*-home-manager-files ]] && [ "$reason" != *"desktop entry"* ]; then
          return 0
        fi
      fi

      if [ "$DRY_RUN" -eq 1 ]; then
        echo "  [DRY-RUN] Removeria: $path ($reason)"
      else
        if [ "$VERBOSE" -eq 1 ] || [ -t 1 ]; then
          echo "  🧹 Removido: $path ($reason)"
        fi
        rm -rf "$path" 2>/dev/null || true
      fi
    }

    echo "🧹 [clean-orphaned-configs] Verificando aplicações removidas e configurações residuais..."

    # -------------------------------------------------------------------------
    # 1. Limpeza Declarativa de Módulos Inativos do Nixfiles
    # -------------------------------------------------------------------------
    ${declarativeCleanupCommands}

    # -------------------------------------------------------------------------
    # 2. Caminhos Extras Configurados pelo Usuário
    # -------------------------------------------------------------------------
    ${concatStringsSep "\n" (
      map (p: ''
        for target in ${p}; do
          if [ -e "$target" ] || [ -L "$target" ]; then
            remove_path "$target" "extraPath"
          fi
        done
      '') cfg.extraPaths
    )}

    # -------------------------------------------------------------------------
    # 3. Comparação Dinâmica de Gerações (se $OLD_GEN e $NEW_GEN fornecidos)
    # Identifica pacotes com arquivos .desktop que sumiram entre gerações
    # -------------------------------------------------------------------------
    if [ -n "$OLD_GEN" ] && [ -n "$NEW_GEN" ] && [ -d "$OLD_GEN" ] && [ -d "$NEW_GEN" ]; then
      old_apps_dir="$OLD_GEN/home-path/share/applications"
      new_apps_dir="$NEW_GEN/home-path/share/applications"
      if [ ! -d "$old_apps_dir" ] && [ -d "$OLD_GEN/share/applications" ]; then
        old_apps_dir="$OLD_GEN/share/applications"
      fi
      if [ ! -d "$new_apps_dir" ] && [ -d "$NEW_GEN/share/applications" ]; then
        new_apps_dir="$NEW_GEN/share/applications"
      fi

      if [ -d "$old_apps_dir" ] && [ -d "$new_apps_dir" ]; then
        for old_desktop in "$old_apps_dir"/*.desktop; do
          [ -e "$old_desktop" ] || continue
          desktop_basename="$(basename "$old_desktop")"

          # Se o atalho não existe mais na nova geração, a aplicação foi removida do Nix!
          if [ ! -e "$new_apps_dir/$desktop_basename" ]; then
            raw_name="''${desktop_basename%.desktop}"
            # Extrai o nome sem o prefixo reverse-DNS (ex: org.gnome.Nautilus -> Nautilus)
            short_name="$(echo "$raw_name" | sed -E 's/^([a-zA-Z0-9_-]+\.)+//')"
            lower_short="$(echo "$short_name" | tr '[:upper:]' '[:lower:]')"
            lower_raw="$(echo "$raw_name" | tr '[:upper:]' '[:lower:]')"

            for cand in "$short_name" "$lower_short" "$raw_name" "$lower_raw"; do
              [ -n "$cand" ] || continue
              if is_protected "$cand"; then
                continue
              fi

              # Limpeza em ~/.config
              if [ -d "$HOME/.config/$cand" ] && [ ! -L "$HOME/.config/$cand" ]; then
                remove_path "$HOME/.config/$cand" "removido na geração ($cand)"
              fi

              ${optionalString cfg.cleanCaches ''
                # Limpeza em ~/.cache
                if [ -d "$HOME/.cache/$cand" ]; then
                  remove_path "$HOME/.cache/$cand" "cache de removido ($cand)"
                fi
              ''}

              ${optionalString cfg.cleanData ''
                # Limpeza em ~/.local/share
                if [ -d "$HOME/.local/share/$cand" ] && [ ! -L "$HOME/.local/share/$cand" ]; then
                  remove_path "$HOME/.local/share/$cand" "share de removido ($cand)"
                fi
              ''}

              # Limpeza de atalhos residuais
              for dt in "$HOME/.local/share/applications/"*"$cand"*.desktop; do
                if [ -e "$dt" ] || [ -L "$dt" ]; then
                  remove_path "$dt" "desktop de removido ($cand)"
                fi
              done
            done
          fi
        done
      fi
    fi

    ${optionalString cfg.cleanBrokenSymlinks ''
      # -------------------------------------------------------------------------
      # 4. Remover Links Simbólicos Quebrados (Dangling Symlinks)
      # -------------------------------------------------------------------------
      if [ -d "$HOME/.local/share/applications" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
          find "$HOME/.local/share/applications" -xtype l -exec echo "  [DRY-RUN] Link quebrado: {}" \; 2>/dev/null || true
        else
          find "$HOME/.local/share/applications" -xtype l -delete 2>/dev/null || true
        fi
      fi
    ''}

    ${optionalString cfg.cleanOrphanedDesktops ''
      # -------------------------------------------------------------------------
      # 5. Remover Arquivos .desktop com Exec= Apontando para Store Paths Mortos
      # -------------------------------------------------------------------------
      if [ -d "$HOME/.local/share/applications" ]; then
        for dt in "$HOME/.local/share/applications"/*.desktop; do
          [ -e "$dt" ] || continue
          # Ignora links simbólicos válidos
          if [ -L "$dt" ] && [ -e "$dt" ]; then
            continue
          fi
          exec_path="$(grep -E '^Exec=' "$dt" 2>/dev/null | head -n1 | cut -d= -f2- | awk '{print $1}' || true)"
          if [[ "$exec_path" =~ ^/nix/store/ ]] && [ ! -e "$exec_path" ]; then
            remove_path "$dt" "execução em nix store path inexistente"
          fi
        done
      fi
    ''}

    # -------------------------------------------------------------------------
    # 6. Atualização de Bancos de Dados e Limpeza de Cache de Launchers (Rofi)
    # -------------------------------------------------------------------------
    if [ "$DRY_RUN" -eq 0 ]; then
      # Limpa histórico e cache drun do Rofi para desocupar memória e eliminar itens removidos
      rm -f "$HOME/.cache/rofi"* "$HOME/.cache/rofi3.druncache" "$HOME/.cache/rofi-"*.cache 2>/dev/null || true

      if command -v update-desktop-database >/dev/null 2>&1 && [ -d "$HOME/.local/share/applications" ]; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
      fi

      if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d "$HOME/.local/share/icons" ]; then
        gtk-update-icon-cache --force --ignore-theme-index "$HOME/.local/share/icons" 2>/dev/null || true
      fi
    fi

    echo "󰄬  [clean-orphaned-configs] Limpeza concluída com sucesso!"
  '';
in
{
  options.system.cleanup = {
    enable = lib.my.mkBool true ''
      Ativa a limpeza automática e declarativa de configurações residuais (~/.config),
      caches (~/.cache), dados locais (~/.local/share) e atalhos de desktop de qualquer
      aplicação que tenha sido removida ou desativada no Nixfiles.
    '';

    cleanCaches = lib.my.mkBool true "Remove diretórios de cache (~/.cache/<app>) de aplicações desativadas.";

    cleanData = lib.my.mkBool true "Remove diretórios de dados locais (~/.local/share/<app>) de aplicações desativadas.";

    cleanBrokenSymlinks = lib.my.mkBool true "Remove links simbólicos corrompidos em ~/.local/share/applications e ~/.config.";

    cleanOrphanedDesktops = lib.my.mkBool true "Remove arquivos .desktop residuais cujos binários apontem para store paths inexistentes.";

    extraPaths =
      lib.my.mkListOf lib.types.str [ ]
        "Lista adicional de diretórios ou arquivos a serem limpos caso existam.";
  };

  config = mkIf cfg.enable {
    # Disponibiliza o utilitário no PATH do usuário
    home.packages = [
      cleanupScript
      (pkgs.writeShellScriptBin "hm-clean-apps" ''
        exec ${cleanupScript}/bin/clean-orphaned-configs "$@"
      '')
    ];

    # Hook de ativação automático no Home Manager (executa em todo switch)
    home.activation.cleanupOrphanedConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${cleanupScript}/bin/clean-orphaned-configs \
        ''${oldGenPath:+--old-gen "$oldGenPath"} \
        ''${newGenPath:+--new-gen "$newGenPath"}
    '';
  };
}
