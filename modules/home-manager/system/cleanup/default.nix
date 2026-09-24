{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatMapStringsSep
    concatStringsSep
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    optionalString
    types
    ;

  cfg = config.system.cleanup;

  # ---------------------------------------------------------------------------
  # Registro Declarativo de Aplicações Conhecidas
  # Mapeia cada módulo para seus diretórios de configuração (~/.config),
  # caches (~/.cache), dados locais (~/.local/share) e atalhos (.desktop).
  # ---------------------------------------------------------------------------
  knownApps = [
    # --- Gerenciadores de Arquivos ---
    {
      name = "spacefm";
      enabled = false; # Removido permanentemente
      configs = [ "$HOME/.config/spacefm" ];
      caches = [ "$HOME/.cache/spacefm" ];
      data = [ "$HOME/.local/share/spacefm" ];
      desktops = [ "$HOME/.local/share/applications/spacefm*.desktop" ];
    }
    {
      name = "thunar";
      enabled = config.system.programs.file-manager.thunar.enable or false;
      configs = [
        "$HOME/.config/Thunar"
        "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
      ];
      caches = [ "$HOME/.cache/Thunar" ];
      data = [ "$HOME/.local/share/Thunar" ];
      desktops = [
        "$HOME/.local/share/applications/thunar*.desktop"
        "$HOME/.local/share/applications/Thunar*.desktop"
      ];
    }
    {
      name = "nautilus";
      enabled = config.system.programs.file-manager.nautilus.enable or false;
      configs = [ "$HOME/.config/nautilus" ];
      caches = [ "$HOME/.cache/nautilus" ];
      data = [ "$HOME/.local/share/nautilus" ];
      desktops = [ "$HOME/.local/share/applications/org.gnome.Nautilus*.desktop" ];
    }
    {
      name = "nemo";
      enabled = config.system.programs.file-manager.nemo.enable or false;
      configs = [ "$HOME/.config/nemo" ];
      caches = [ "$HOME/.cache/nemo" ];
      data = [ "$HOME/.local/share/nemo" ];
      desktops = [ "$HOME/.local/share/applications/nemo*.desktop" ];
    }
    {
      name = "pcmanfm";
      enabled = config.system.programs.file-manager.pcmanfm.enable or false;
      configs = [ "$HOME/.config/pcmanfm" ];
      caches = [ "$HOME/.cache/pcmanfm" ];
      data = [ "$HOME/.local/share/pcmanfm" ];
      desktops = [ "$HOME/.local/share/applications/pcmanfm*.desktop" ];
    }
    {
      name = "catfish";
      # Catfish é utilitário de busca integrado ao Thunar e XFCE4
      enabled =
        (config.system.programs.file-manager.thunar.enable or false)
        || (config.desktop.environments.xfce4.enable or false);
      configs = [ "$HOME/.config/catfish" ];
      caches = [ "$HOME/.cache/catfish" ];
      data = [ "$HOME/.local/share/catfish" ];
      desktops = [ "$HOME/.local/share/applications/org.xfce.Catfish*.desktop" ];
    }

    # --- Comunicação / Chat ---
    {
      name = "discord";
      enabled = config.system.programs.chat.discord.enable or false;
      configs = [
        "$HOME/.config/discord"
        "$HOME/.config/BetterDiscord"
        "$HOME/.config/Vencord"
      ];
      caches = [ "$HOME/.cache/discord" ];
      data = [ "$HOME/.local/share/discord" ];
      desktops = [ "$HOME/.local/share/applications/*discord*.desktop" ];
    }

    # --- Editores ---
    {
      name = "vscode";
      enabled = config.system.programs.editors.vscode.enable or false;
      configs = [ "$HOME/.config/Code" ];
      caches = [ "$HOME/.cache/vscode-cpptools" ];
      data = [ ];
      desktops = [ ];
    }

    # --- Terminais ---
    {
      name = "alacritty";
      enabled =
        (config.system.programs.terminal.enable or false)
        && ((config.system.programs.terminal.name or "") == "alacritty");
      configs = [ "$HOME/.config/alacritty" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "kitty";
      enabled =
        (config.system.programs.terminal.enable or false)
        && ((config.system.programs.terminal.name or "") == "kitty");
      configs = [ "$HOME/.config/kitty" ];
      caches = [ "$HOME/.cache/kitty" ];
      data = [ ];
      desktops = [ ];
    }

    # --- Multimídia ---
    {
      name = "sonixd";
      enabled = config.system.programs.multimedia.sonixd.enable or false;
      configs = [ "$HOME/.config/sonixd" ];
      caches = [ "$HOME/.cache/sonixd" ];
      data = [ ];
      desktops = [ "$HOME/.local/share/applications/*sonixd*.desktop" ];
    }
    {
      name = "rhythmbox";
      enabled = config.system.programs.multimedia.rhythmbox.enable or false;
      configs = [ "$HOME/.config/rhythmbox" ];
      caches = [ "$HOME/.cache/rhythmbox" ];
      data = [ "$HOME/.local/share/rhythmbox" ];
      desktops = [ "$HOME/.local/share/applications/*rhythmbox*.desktop" ];
    }
    {
      name = "audio-recorder";
      enabled = config.system.programs.multimedia.audio-recorder.enable or false;
      configs = [ "$HOME/.config/audio-recorder" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "ncmpcpp";
      enabled = config.system.programs.multimedia.ncmpcpp.enable or false;
      configs = [ "$HOME/.config/ncmpcpp" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }

    # --- Ferramentas / Utilitários ---
    {
      name = "bleachbit";
      enabled = config.system.programs.tools.bleachbit.enable or false;
      configs = [ "$HOME/.config/bleachbit" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "flameshot";
      enabled = config.system.programs.tools.flameshot.enable or false;
      configs = [ "$HOME/.config/flameshot" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
    {
      name = "meld";
      enabled = config.system.programs.tools.meld.enable or false;
      configs = [ "$HOME/.config/meld" ];
      caches = [ ];
      data = [ "$HOME/.local/share/meld" ];
      desktops = [ ];
    }

    # --- Documentos ---
    {
      name = "zathura";
      enabled = config.system.programs.documents.zathura.enable or false;
      configs = [ "$HOME/.config/zathura" ];
      caches = [ ];
      data = [ "$HOME/.local/share/zathura" ];
      desktops = [ ];
    }
    {
      name = "libreoffice";
      enabled = config.system.programs.documents.libreoffice.enable or false;
      configs = [ "$HOME/.config/libreoffice" ];
      caches = [ ];
      data = [ ];
      desktops = [ ];
    }
  ];

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

    echo "✨ [clean-orphaned-configs] Limpeza concluída com sucesso!"
  '';
in
{
  options.system.cleanup = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Ativa a limpeza automática e declarativa de configurações residuais (~/.config),
        caches (~/.cache), dados locais (~/.local/share) e atalhos de desktop de qualquer
        aplicação que tenha sido removida ou desativada no Nixfiles.
      '';
    };

    cleanCaches = mkOption {
      type = types.bool;
      default = true;
      description = "Remove diretórios de cache (~/.cache/<app>) de aplicações desativadas.";
    };

    cleanData = mkOption {
      type = types.bool;
      default = true;
      description = "Remove diretórios de dados locais (~/.local/share/<app>) de aplicações desativadas.";
    };

    cleanBrokenSymlinks = mkOption {
      type = types.bool;
      default = true;
      description = "Remove links simbólicos corrompidos em ~/.local/share/applications e ~/.config.";
    };

    cleanOrphanedDesktops = mkOption {
      type = types.bool;
      default = true;
      description = "Remove arquivos .desktop residuais cujos binários apontem para store paths inexistentes.";
    };

    extraPaths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Lista adicional de diretórios ou arquivos a serem limpos caso existam.";
    };
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
