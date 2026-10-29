{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    optionals
    ;

  cfg = config.system.programs.file-manager.nautilus;
  shouldInstall = cfg.installPackage && !cfg.useSystemPackage && !cfg.useSystemPackages;

  # Terminal padrão para integração com nautilus-open-any-terminal
  preferredTerminal =
    if config.programs ? alacritty && config.programs.alacritty.enable then "alacritty" else "auto";

  # Wrapper para garantir suporte a GVfs (Samba/SMB, Rede, Lixeira, MTP, SFTP),
  # Schemas do GSettings, extensões e plugins do Nautilus
  nautilus-wrapped = pkgs.symlinkJoin {
    name = "nautilus-wrapped";
    paths = [ cfg.package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -rf $out/bin
      mkdir -p $out/bin

      for bin in ${cfg.package}/bin/*; do
        if [ -x "$bin" ]; then
          makeWrapper "$bin" "$out/bin/$(basename "$bin")" \
            --prefix GIO_EXTRA_MODULES : "${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules" \
            --prefix XDG_DATA_DIRS : "${pkgs.gvfs}/share:${pkgs.gsettings-desktop-schemas}/share:${pkgs.nautilus}/share:${pkgs.sushi}/share:${pkgs.nautilus-open-any-terminal}/share:${pkgs.tumbler}/share:${pkgs.shared-mime-info}/share:/usr/share" \
            --prefix NAUTILUS_4_EXTENSION_DIR : "${pkgs.nautilus-python}/lib/nautilus/extensions-4"
        fi
      done
    '';
  };
in
{
  options = {
    # Alias legado para compatibilidade com configurações anteriores
    programs.nautilus = {
      enable = lib.my.mkBool false "Alias legado para system.programs.file-manager.nautilus.enable.";
    };

    system.programs.file-manager.nautilus = {
      enable = mkEnableOption "Enable GNOME Files (Nautilus) with GVfs, Sushi preview, extensions, dconf settings, and custom scripts.";

      installPackage = lib.my.mkBool true ''
        Se deve instalar o executável do Nautilus compilado via Nix/Home Manager.
        Se false, utiliza o binário da distro nativa (ex: Debian /usr/bin/nautilus), mantendo configurações, extensões e scripts.
      '';

      useSystemPackage = lib.my.mkBool false ''
        Atalho conveniente: quando true, equivale a installPackage = false.
        Permite carregar apenas as configurações, scripts e extensões preservando o Nautilus da distribuição nativa.
      '';

      useSystemPackages = lib.my.mkBool false "Alias para useSystemPackage.";

      package = lib.my.mkPkg pkgs.nautilus "Pacote do Nautilus a ser utilizado.";

      openAnyTerminal = {
        enable = lib.my.mkBool true "Habilitar extensão nautilus-open-any-terminal.";

        terminal = lib.my.mkStr preferredTerminal "Terminal preferido para o nautilus-open-any-terminal (ex: alacritty, kitty, auto).";

        keybinding = lib.my.mkStr "<Ctrl><Alt>t" "Atalho de teclado para abrir o terminal no diretório atual.";
      };

      sushi = {
        enable = lib.my.mkBool true "Habilitar GNOME Sushi (pré-visualização rápida com Barra de Espaço).";
      };

      view = {
        defaultView = lib.my.mkEnum [
          "icon-view"
          "list-view"
        ] "icon-view" "Modo de visualização padrão de pastas no Nautilus.";

        useTreeView = lib.my.mkBool true "Habilitar expansão em árvore de pastas (tree view) no modo lista.";

        sortDirectoriesFirst = lib.my.mkBool true "Exibir pastas antes dos arquivos na ordenação.";

        showDeletePermanently = lib.my.mkBool true "Exibir opção 'Excluir Permanentemente' no menu de contexto (sem passar pela lixeira).";

        showCreateLink = lib.my.mkBool true "Exibir opção 'Criar Link' no menu de contexto.";
      };
    };
  };

  config = mkMerge [
    (mkIf (config.programs.nautilus.enable or false) {
      system.programs.file-manager.nautilus.enable = true;
    })
    (mkIf cfg.enable {
      # Configurações dconf / GSettings para Nautilus, GTK e extensões
      dconf.settings = {
        "org/gnome/nautilus/preferences" = {
          always-use-location-entry = false;
          show-delete-permanently = cfg.view.showDeletePermanently;
          show-create-link = cfg.view.showCreateLink;
          default-folder-viewer = cfg.view.defaultView;
          search-filter-time-type = "last_modified";
          search-view = "list-view";
        };

        "org/gnome/nautilus/list-view" = {
          use-tree-view = cfg.view.useTreeView;
          default-zoom-level = "small";
        };

        "org/gnome/nautilus/icon-view" = {
          default-zoom-level = "medium";
          captions = [
            "size"
            "date_modified"
            "none"
          ];
        };

        "org/gnome/nautilus/compression" = {
          default-compression-format = "zip";
        };

        "org/gtk/gtk4/settings/file-chooser" = {
          sort-directories-first = cfg.view.sortDirectoriesFirst;
          clock-format = "24h";
        };

        "org/gtk/Settings/FileChooser" = {
          sort-directories-first = cfg.view.sortDirectoriesFirst;
          clock-format = "24h";
        };

        "org/gnome/desktop/privacy" = {
          remember-recent-files = true;
        };

        "com/github/stunkymonkey/nautilus-open-any-terminal" = mkIf cfg.openAnyTerminal.enable {
          terminal = cfg.openAnyTerminal.terminal;
          keybindings = cfg.openAnyTerminal.keybinding;
          new-tab = false;
          flatpak-system = false;
        };
      };

      home = {
        # Variáveis de sessão para suporte a extensões e temas
        sessionVariables = {
          NAUTILUS_4_EXTENSION_DIR = "${pkgs.nautilus-python}/lib/nautilus/extensions-4\${NAUTILUS_4_EXTENSION_DIR:+:$NAUTILUS_4_EXTENSION_DIR}";
        };

        # Pacotes essenciais, extensões e geradores de miniaturas (thumbnails)
        packages =
          optionals shouldInstall [
            nautilus-wrapped
          ]
          ++ [
            pkgs.gvfs
            pkgs.nautilus-python
            pkgs.file-roller
            pkgs.ffmpegthumbnailer
            pkgs.webp-pixbuf-loader
            pkgs.poppler
            pkgs.libgsf
            pkgs.freetype
            pkgs.meld
            pkgs.zenity
            pkgs.imagemagick
            pkgs.qrencode
          ]
          ++ optionals cfg.openAnyTerminal.enable [
            pkgs.nautilus-open-any-terminal
          ]
          ++ optionals cfg.sushi.enable [
            pkgs.sushi
          ];

        # Scripts no menu de contexto do Nautilus
        file = {
          # Scripts do Nautilus (~/.local/share/nautilus/scripts/)
          ".local/share/nautilus/scripts/Abrir no VSCode" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              if [ -n "$1" ]; then
                code "$@"
              else
                code "''${NAUTILUS_SCRIPT_CURRENT_URI#file://}"
              fi
            '';
          };

          ".local/share/nautilus/scripts/Abrir no Antigravity" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              if [ -n "$1" ]; then
                antigravity-ide "$@"
              else
                antigravity-ide "''${NAUTILUS_SCRIPT_CURRENT_URI#file://}"
              fi
            '';
          };

          ".local/share/nautilus/scripts/Abrir como Administrador" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              TARGET="''${1:-$NAUTILUS_SCRIPT_CURRENT_URI}"
              TARGET="''${TARGET#file://}"
              [ -z "$TARGET" ] && TARGET="$HOME"
              pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" nautilus "$TARGET" 2>/dev/null || pkexec nautilus "$TARGET"
            '';
          };

          ".local/share/nautilus/scripts/Comparar com Meld" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              ${pkgs.meld}/bin/meld "$@"
            '';
          };

          ".local/share/nautilus/scripts/Copiar Caminho Completo" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              PATHS=""
              for f in "$@"; do
                ABS=$(realpath "$f")
                PATHS="''${PATHS}''${ABS}\n"
              done
              PATHS=$(printf "%b" "$PATHS" | sed '/^$/d')
              if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
                printf "%s" "$PATHS" | wl-copy
              elif command -v xclip >/dev/null 2>&1; then
                printf "%s" "$PATHS" | xclip -selection clipboard
              fi
              command -v notify-send >/dev/null 2>&1 && notify-send -i edit-copy "Nautilus" "Caminho copiado para a área de transferência!"
            '';
          };

          ".local/share/nautilus/scripts/Verificar Checksum (SHA256)" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              if [ $# -eq 0 ]; then
                exit 0
              fi
              OUTPUT=""
              for f in "$@"; do
                if [ -f "$f" ]; then
                  HASH=$(sha256sum "$f" | awk '{print $1}')
                  OUTPUT="''${OUTPUT}Arquivo: $(basename "$f")\nSHA256: ''${HASH}\n\n"
                fi
              done
              if command -v zenity >/dev/null 2>&1; then
                printf "%b" "$OUTPUT" | zenity --text-info --title="Checksum SHA256" --width=620 --height=260
              elif command -v notify-send >/dev/null 2>&1; then
                notify-send -i dialog-information "Checksum SHA256" "$OUTPUT"
              fi
            '';
          };

          ".local/share/nautilus/scripts/Converter Imagem para WebP" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              COUNT=0
              for img in "$@"; do
                if [ -f "$img" ]; then
                  out="''${img%.*}.webp"
                  ${pkgs.imagemagick}/bin/magick "$img" -quality 85 "$out" && COUNT=$((COUNT + 1))
                fi
              done
              if [ "$COUNT" -gt 0 ]; then
                command -v notify-send >/dev/null 2>&1 && notify-send -i image-x-generic "Nautilus" "$COUNT imagem(ns) convertida(s) para WebP!"
              fi
            '';
          };

          ".local/share/nautilus/scripts/Definir como Papel de Parede" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              IMG="$1"
              [ -z "$IMG" ] && exit 0
              ABS_IMG=$(realpath "$IMG")

              if command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
                hyprctl hyprpaper preload "$ABS_IMG" 2>/dev/null
                hyprctl hyprpaper wallpaper ",$ABS_IMG" 2>/dev/null
              elif command -v feh >/dev/null 2>&1; then
                feh --bg-fill "$ABS_IMG"
              elif command -v gsettings >/dev/null 2>&1; then
                gsettings set org.gnome.desktop.background picture-uri "file://$ABS_IMG"
                gsettings set org.gnome.desktop.background picture-uri-dark "file://$ABS_IMG"
              fi
              command -v notify-send >/dev/null 2>&1 && notify-send -i preferences-desktop-wallpaper "Nautilus" "Papel de parede atualizado!"
            '';
          };

          ".local/share/nautilus/scripts/Gerar QR Code" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              ITEM="$1"
              [ -z "$ITEM" ] && exit 0
              TMP_PNG=$(mktemp /tmp/qrcode-XXXXXX.png)
              ${pkgs.qrencode}/bin/qrencode -s 8 -o "$TMP_PNG" "$ITEM"
              if command -v feh >/dev/null 2>&1; then
                feh --title "QR Code - $ITEM" "$TMP_PNG"
              elif command -v zenity >/dev/null 2>&1; then
                zenity --image="$TMP_PNG" --title="QR Code" --text="QR Code para: $ITEM"
              fi
              rm -f "$TMP_PNG"
            '';
          };
        };
      };
    })
  ];
}
