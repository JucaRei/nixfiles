{
  config,
  lib,
  pkgs,
  useNixGL ? false,
  desktop ? null,
  nixGLType ? null,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool str;
  cfg = config.desktop.dwm;

  isNvidiaLegacy = (osConfig.hardware.graphics.cards.gpu or null) == "nvidia-legacy";

  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs nixGLType; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);

  # DWM construído a partir do código-fonte e C configs da pasta ./configs
  dwmPackage = pkgs.stdenv.mkDerivation {
    pname = "dwm-titus";
    version = "0.7.2";

    src = ./configs;

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.python3
    ];

    # Dependências declaradas no repositório (config.mk / PKG_MODULES)
    buildInputs = with pkgs; [
      libx11
      libxft
      libxinerama
      libxrender
      libxcursor
      libxcb
      imlib2
      fontconfig
      freetype
    ];

    makeFlags = [
      "PKG_CONFIG=${pkgs.pkg-config}/bin/pkg-config"
      "PREFIX=$(out)"
      "MANPREFIX=$(out)/share/man"
    ];

    preInstall = ''
      mkdir -p $out/bin $out/share/man/man1
    '';

    postInstall = ''
      mkdir -p $out/bin $out/share/dwm-titus/scripts $out/share/dwm-titus/config
      if [ -d ./scripts ]; then
        find ./scripts -maxdepth 1 -type f -exec cp -f {} $out/bin/ \;
        cp -rf ./scripts/* $out/share/dwm-titus/scripts/ 2>/dev/null || true
        cp -rf ./config/* $out/share/dwm-titus/config/ 2>/dev/null || true
        chmod +x $out/bin/* || true
      elif [ -d "$src/scripts" ]; then
        find "$src/scripts" -maxdepth 1 -type f -exec cp -f {} $out/bin/ \;
        cp -rf "$src/scripts"/* $out/share/dwm-titus/scripts/ 2>/dev/null || true
        cp -rf "$src/config"/* $out/share/dwm-titus/config/ 2>/dev/null || true
        chmod +x $out/bin/* || true
      fi
    '';
  };
in
{
  options.desktop.dwm = {
    enable = mkOption {
      type = bool;
      default = (desktop == "dwm");
      description = "Enable DWM window manager with custom config.def.h and dwm-titus runtime configuration";
    };

    modifierKey = mkOption {
      type = str;
      default = config.desktop.modifierKey or "Super";
      description = "Tecla modificadora principal do DWM (Super ou Alt).";
    };

    bar = mkOption {
      type = lib.types.enum [ "quickshell" "dwm-status" "slstatus" "polybar" "none" ];
      default = "quickshell";
      description = "Barra de status/painel do DWM. Opções: 'quickshell' (painel moderno do dwm-titus com launcher e control center), 'dwm-status' (script de status nativo do dwm usando xsetroot), 'slstatus', 'polybar' ou 'none'.";
    };

    quickshell = {
      enable = mkOption {
        type = lib.types.bool;
        default = (cfg.bar == "quickshell");
        description = "Habilitar Quickshell no DWM";
      };

      qsgBackend = mkOption {
        type = lib.types.enum [ "opengl" "software" "vulkan" "auto" ];
        default = if isNvidiaLegacy then "software" else "opengl";
        description = "Backend de renderização do Qt Quick Scene Graph (QSG_RHI_BACKEND). No NVIDIA 340 Legacy (sem suporte a Vulkan e com FBConfigs GLX incompatíveis no Qt 6.11), 'software' garante renderização estável via CPU.";
      };

      glIntegration = mkOption {
        type = lib.types.enum [ "glx" "egl" "auto" "none" ];
        default = if isNvidiaLegacy then "none" else "auto";
        description = "Backend de integração GL do Qt XCB (QT_XCB_GL_INTEGRATION). No NVIDIA 340 Legacy, 'none' previne falhas de contexto dummy GLX/EGL no Qt6.";
      };
    };

    keyboard = {
      brightness = {
        enable = mkOption {
          type = lib.types.bool;
          default = true;
          description = "Habilitar script dwm-kbd-brightness-osd e atalhos de iluminação do teclado com OSD Dunst";
        };

        device = mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Dispositivo específico em /sys/class/leds (ex: 'smc::kbd_backlight'), ou null para detecção automática";
        };

        step = mkOption {
          type = lib.types.int;
          default = 5;
          description = "Passo de alteração de brilho do teclado em porcentagem (padrão 5%)";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      windowManager = {
        command = ''
          # 1. Configuração do teclado herdada declarativamente de home.keyboard
          ${lib.optionalString (config.home.keyboard != null) ''
            ${pkgs.setxkbmap}/bin/setxkbmap \
              ${lib.optionalString (config.home.keyboard.model != null) "-model '${config.home.keyboard.model}'"} \
              ${lib.optionalString (config.home.keyboard.layout != null) "-layout '${config.home.keyboard.layout}'"} \
              ${lib.optionalString (config.home.keyboard.variant != null) "-variant '${config.home.keyboard.variant}'"} \
              ${lib.concatMapStringsSep " " (opt: "-option '${opt}'") (config.home.keyboard.options or [ ])} || true
          ''}

          # 2. Carregar bibliotecas de driver gráfico proprietário legado SE E SOMENTE SE NVIDIA 340 detectada
          # No Mesa/Nouveau padrão, LD_LIBRARY_PATH não deve ser exportado pois sobrepõe o libglvnd do Nixpkgs
          # causando "symbol lookup error: undefined symbol: eglDestroyImage" no Quickshell e aplicativos Qt6.
          if [ -d /proc/driver/nvidia ] || [ -f /run/opengl-driver/lib/libGL.so.340.108 ] || [ -f /usr/lib64/nvidia/libGL.so.340.108 ] || [ -f /usr/lib/x86_64-linux-gnu/libGL.so.340.108 ]; then
            if [ -d /run/opengl-driver/lib ] && [ -f /run/opengl-driver/lib/libGL.so.1 ]; then
              export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            fi
          fi

          # 3. Forçar ambiente gráfico X11 e Qt6 para máxima compatibilidade com GPUs legadas
          export QT_QPA_PLATFORM=xcb
          unset WAYLAND_DISPLAY

          # Qt Quick Scene Graph / RHI backend configurado declarativamente
          ${lib.optionalString (cfg.quickshell.qsgBackend != "auto") ''
            export QSG_RHI_BACKEND="${cfg.quickshell.qsgBackend}"
            ${lib.optionalString (cfg.quickshell.qsgBackend == "software") ''
              export QT_QUICK_BACKEND=software
            ''}
          ''}
          ${lib.optionalString (cfg.quickshell.glIntegration != "auto") ''
            export QT_XCB_GL_INTEGRATION="${cfg.quickshell.glIntegration}"
          ''}

          # Se detectada GPU NVIDIA 340 Legacy (monolítica GLX pré-libglvnd), forçar parâmetros estáveis
          if [ -d /proc/driver/nvidia ] || [ -f /run/opengl-driver/lib/libGL.so.340.108 ] || [ -f /usr/lib64/nvidia/libGL.so.340.108 ] || [ -f /usr/lib/x86_64-linux-gnu/libGL.so.340.108 ]; then
            export __GL_VRR_ALLOWED=0
            export LIBGL_ALWAYS_INDIRECT=0
          fi

          ${lib.optionalString (cfg.keyboard.brightness.device != null) ''
            export DWM_KBD_BACKLIGHT_DEVICE="${cfg.keyboard.brightness.device}"
          ''}
          export DWM_KBD_BRIGHTNESS_STEP="${toString cfg.keyboard.brightness.step}"

          # 4. Carregar recursos do X11 (incluindo tema e tamanho de cursor Xcursor)
          [ -f "$HOME/.Xresources" ] && ${pkgs.xrdb}/bin/xrdb -merge "$HOME/.Xresources" || true
          [ -f "$HOME/.config/dwm-titus/cursor.Xresources" ] && ${pkgs.xrdb}/bin/xrdb -merge "$HOME/.config/dwm-titus/cursor.Xresources" || true

          # 5. Importar variáveis de ambiente para serviços do usuário
          systemctl --user import-environment DISPLAY XAUTHORITY LD_LIBRARY_PATH LIBVA_DRIVER_NAME VDPAU_DRIVER QT_QPA_PLATFORM QSG_RHI_BACKEND QT_XCB_GL_INTEGRATION DWM_KBD_BACKLIGHT_DEVICE DWM_KBD_BRIGHTNESS_STEP XCURSOR_THEME XCURSOR_SIZE 2>/dev/null || true
          systemctl --user start graphical-session.target 2>/dev/null || true

          # 6. Agente de autenticação Polkit (Agnóstico de distro)
          ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &

          # 7. Wallpaper / Fundo e Cursor padrão (gerenciado via feh)
          xsetroot -solid '#1e1e2e' -cursor_name left_ptr &
          if [ -f "$HOME/.fehbg" ]; then
            sh "$HOME/.fehbg" &
          fi

          # 8. Applet de Rede (após importar DISPLAY)
          ${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable &

          # 9. Configurar Touchpad vs Mouse:
          # - Touchpad: Natural Scrolling (estilo macOS), Tapping e Clickfinger ativados
          # - Mouse: Natural Scrolling DESATIVADO (rolagem padrão tradicional)
          if command -v ${pkgs.xinput}/bin/xinput >/dev/null 2>&1; then
            for id in $(${pkgs.xinput}/bin/xinput list --id-only 2>/dev/null); do
              dev_name=$(${pkgs.xinput}/bin/xinput list --name-only "$id" 2>/dev/null | tr '[:upper:]' '[:lower:]')
              has_tapping=$(${pkgs.xinput}/bin/xinput list-props "$id" 2>/dev/null | grep -c "libinput Tapping Enabled" || true)

              if echo "$dev_name" | grep -q "touchpad" || [ "$has_tapping" -gt 0 ]; then
                ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Natural Scrolling Enabled" 1 2>/dev/null || true
                ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Tapping Enabled" 1 2>/dev/null || true
                ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Click Method Enabled" 0 1 2>/dev/null || true
              else
                if ${pkgs.xinput}/bin/xinput list-props "$id" 2>/dev/null | grep -q "libinput Natural Scrolling Enabled"; then
                  ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Natural Scrolling Enabled" 0 2>/dev/null || true
                fi
              fi
            done
          fi

          # 10. Iniciar compositor Picom se habilitado
          ${lib.optionalString config.desktop.dwm.picom.enable ''
            pkill -x picom || true
            systemctl --user restart picom 2>/dev/null || (${pkgs.picom}/bin/picom -b 2>/dev/null || true) &
          ''}

          # 11. Iniciar Barra de Status / Painel configurado declarativamente
          mkdir -p "$HOME/.local/state/dwm-titus"
          ${if cfg.bar == "quickshell" then ''
            pkill -x quickshell || true
            pkill -x slstatus || true
            pkill -x dwm-status || true

            # Iniciar Quickshell com log para diagnóstico (isolando de LD_LIBRARY_PATH e forçando backend de software/none quando configurado)
            env -u LD_LIBRARY_PATH \
              ${lib.optionalString (cfg.quickshell.qsgBackend == "software") "QT_QUICK_BACKEND=software QSG_RHI_BACKEND=software"} \
              ${lib.optionalString (cfg.quickshell.glIntegration == "none") "QT_XCB_GL_INTEGRATION=none"} \
              ${nixGLWrapper pkgs.quickshell}/bin/quickshell --path "$HOME/.config/quickshell/shell.qml" --no-duplicate > "$HOME/.local/state/dwm-titus/quickshell.log" 2>&1 &
            QUICKSHELL_PID=$!

            # Watchdog leve em background: se o Quickshell fechar ou falhar na GPU, acionar dwm-status automaticamente
            (
              sleep 3
              if ! kill -0 "$QUICKSHELL_PID" 2>/dev/null && ! pgrep -x quickshell >/dev/null 2>&1; then
                echo "Quickshell falhou em iniciar na GPU. Ativando fallback dwm-status..." >> "$HOME/.local/state/dwm-titus/quickshell.log"
                ${dwmPackage}/bin/dwm-status &
              fi
            ) &
          '' else if cfg.bar == "dwm-status" then ''
            pkill -x quickshell || true
            pkill -x slstatus || true
            pkill -x dwm-status || true
            ${dwmPackage}/bin/dwm-status &
          '' else if cfg.bar == "slstatus" then ''
            pkill -x quickshell || true
            pkill -x dwm-status || true
            pkill -x slstatus || true
            ${pkgs.slstatus}/bin/slstatus &
          '' else if cfg.bar == "polybar" then ''
            pkill -x quickshell || true
            pkill -x dwm-status || true
            pkill -x slstatus || true
            systemctl --user restart polybar 2>/dev/null || true
          '' else ''
            pkill -x quickshell || true
            pkill -x dwm-status || true
            pkill -x slstatus || true
          ''}

          # 12. Executar DWM com nixGL wrapper (para suporte a distros standalone como Fedora/Debian)
          exec ${nixGLWrapper dwmPackage}/bin/dwm
        '';
      };
    };

    home = {
      packages = [
        (nixGLWrapper dwmPackage)
        (nixGLWrapper pkgs.quickshell)
        pkgs.slstatus
        pkgs.polkit_gnome
        pkgs.networkmanagerapplet
        pkgs.xinput
        pkgs.brightnessctl
        pkgs.libnotify
        pkgs.xsetroot
        pkgs.xdg-utils
      ];

      file = {
        # Sessão Desktop para Display Managers (GDM, SDDM, LightDM)
        ".local/share/xsessions/dwm.desktop".text = ''
          [Desktop Entry]
          Name=DWM
          Comment=Dynamic window manager
          Exec=${config.home.homeDirectory}/.local/bin/start-dwm
          Type=Application
          DesktopNames=dwm
        '';

        # Wrapper de inicialização portátil com carregamento do perfil Nix
        ".local/bin/start-dwm" = {
          text = ''
            #!/bin/sh
            if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
              . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            fi
            if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
              . "$HOME/.nix-profile/etc/profile.d/nix.sh"
            fi
            exec "$HOME/.xsession"
          '';
          executable = true;
        };
      };

      sessionVariables = {
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        TERM = "alacritty";
        QT_QPA_PLATFORM = "xcb";
        DWM_KBD_BRIGHTNESS_STEP = toString cfg.keyboard.brightness.step;
      } // lib.optionalAttrs (cfg.keyboard.brightness.device != null) {
        DWM_KBD_BACKLIGHT_DEVICE = cfg.keyboard.brightness.device;
      };

      # Ativação do Home Manager: provisionar ~/.config/dwm-titus e ~/.config/quickshell como diretórios reais e editáveis
      activation.setupDwmConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # 1. Se ~/.config/dwm-titus for symlink do Nix store (geração anterior), remover para permitir escrita
        if [ -L "$HOME/.config/dwm-titus" ]; then
          $DRY_RUN_CMD rm -f "$HOME/.config/dwm-titus"
        fi
        $DRY_RUN_CMD mkdir -p "$HOME/.config/dwm-titus"
        $DRY_RUN_CMD chmod 700 "$HOME/.config/dwm-titus" 2>/dev/null || true
        $DRY_RUN_CMD chmod go-w "$HOME/.config/dwm-titus" 2>/dev/null || true
        $DRY_RUN_CMD mkdir -p "$HOME/.config/dwm-titus/display-profiles"
        $DRY_RUN_CMD chmod 700 "$HOME/.config/dwm-titus/display-profiles" 2>/dev/null || true
        $DRY_RUN_CMD mkdir -p "$HOME/.local/share/dwm-titus/config"
        $DRY_RUN_CMD mkdir -p "$HOME/.local/share/dwm-titus/scripts"
        $DRY_RUN_CMD mkdir -p "$HOME/.local/state/dwm-titus/appearance/wallpaper"
        $DRY_RUN_CMD chmod 700 "$HOME/.local/state/dwm-titus" "$HOME/.local/state/dwm-titus/appearance" "$HOME/.local/state/dwm-titus/appearance/wallpaper" 2>/dev/null || true

        # Sincronizar fallbacks e scripts em ~/.local/share/dwm-titus (usados pelo dwm.c e theme-apply)
        $DRY_RUN_CMD cp -rf ${./configs/config}/* "$HOME/.local/share/dwm-titus/config/" 2>/dev/null || true
        $DRY_RUN_CMD cp -rf ${./configs/scripts}/* "$HOME/.local/share/dwm-titus/scripts/" 2>/dev/null || true
        $DRY_RUN_CMD chmod -R u+w "$HOME/.local/share/dwm-titus" 2>/dev/null || true
        $DRY_RUN_CMD chmod +x "$HOME/.local/share/dwm-titus/scripts/"* 2>/dev/null || true

        # 2. Provisionar ~/.config/quickshell como diretório REAL gravável (permite testar em Live Mode / Hot Reload)
        if [ -L "$HOME/.config/quickshell" ]; then
          $DRY_RUN_CMD rm -f "$HOME/.config/quickshell"
        fi
        $DRY_RUN_CMD mkdir -p "$HOME/.config/quickshell"
        $DRY_RUN_CMD cp -rf ${./configs/config/quickshell}/* "$HOME/.config/quickshell/" 2>/dev/null || true
        $DRY_RUN_CMD chmod -R u+w "$HOME/.config/quickshell" 2>/dev/null || true

        # 3. Inicializar arquivos de configuração do usuário em ~/.config/dwm-titus se não existirem
        if [ ! -f "$HOME/.config/dwm-titus/themes.toml" ]; then
          $DRY_RUN_CMD cp -f ${./configs/config/themes.toml} "$HOME/.config/dwm-titus/themes.toml"
        fi
        if [ ! -f "$HOME/.config/dwm-titus/hotkeys.toml" ]; then
          $DRY_RUN_CMD cp -f ${./configs/config/hotkeys.toml} "$HOME/.config/dwm-titus/hotkeys.toml"
        else
          # Assegurar que a variável filemanager exista no bloco [vars]
          if ! grep -q 'filemanager' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null; then
            $DRY_RUN_CMD sed -i '/\[vars\]/a filemanager = "file-manager"' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
          fi
          # Migrar atalhos legados para o despachante agnóstico de gerenciador de arquivos (file-manager)
          $DRY_RUN_CMD sed -i 's|cmd="xdg-open \."|exec=["$filemanager"]|g' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
          $DRY_RUN_CMD sed -i 's|cmd = "xdg-open \."|exec=["$filemanager"]|g' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
          $DRY_RUN_CMD sed -i 's|cmd="file-manager \|\| thunar \|\| xdg-open ~"|exec=["$filemanager"]|g' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
          $DRY_RUN_CMD sed -i 's|cmd = "file-manager \|\| thunar \|\| xdg-open ~"|exec=["$filemanager"]|g' "$HOME/.config/dwm-titus/hotkeys.toml" 2>/dev/null || true
        fi
        if [ ! -f "$HOME/.config/dwm-titus/window-rules.toml" ]; then
          $DRY_RUN_CMD cp -f ${./configs/config/window-rules.toml} "$HOME/.config/dwm-titus/window-rules.toml"
        fi

        # 4. Todos os arquivos de estado, persistência e integração para os modelos QML do Quickshell
        # (Aparência, Wallpaper, Fontes, Painel, Acessibilidade, Notificações, Picom)
        # Se estiverem ausentes ou vazios (0 bytes - gerados por touch anterior), copiar os templates válidos
        for cfg_file in \
          "theme-env.sh" \
          "personalization.conf" \
          "cursor.Xresources" \
          "xsettingsd.conf" \
          "wallpaper.conf" \
          "font.conf" \
          "accessibility.conf" \
          "panel-widgets.conf" \
          "notification-settings.json" \
          "picom.conf"; do
          if [ -L "$HOME/.config/dwm-titus/$cfg_file" ]; then
            $DRY_RUN_CMD rm -f "$HOME/.config/dwm-titus/$cfg_file"
          fi
          # Se não existir ou tiver 0 bytes: copiar template válido se disponível
          if [ ! -s "$HOME/.config/dwm-titus/$cfg_file" ]; then
            if [ -f "${./configs/config}/$cfg_file" ]; then
              $DRY_RUN_CMD cp -f "${./configs/config}/$cfg_file" "$HOME/.config/dwm-titus/$cfg_file"
            else
              $DRY_RUN_CMD touch "$HOME/.config/dwm-titus/$cfg_file"
            fi
          fi
          $DRY_RUN_CMD chmod 600 "$HOME/.config/dwm-titus/$cfg_file" 2>/dev/null || true
          $DRY_RUN_CMD chmod go-w "$HOME/.config/dwm-titus/$cfg_file" 2>/dev/null || true
        done

        # Limpar arquivo espúrio display-profiles.json se tiver sido criado anteriormente
        if [ -f "$HOME/.config/dwm-titus/display-profiles.json" ]; then
          $DRY_RUN_CMD rm -f "$HOME/.config/dwm-titus/display-profiles.json"
        fi

        # Assegurar permissões estritas para evitar falhas de validação de segurança
        $DRY_RUN_CMD chmod 700 "$HOME/.config/dwm-titus" 2>/dev/null || true
        $DRY_RUN_CMD chmod go-w "$HOME/.config/dwm-titus" 2>/dev/null || true
        $DRY_RUN_CMD chmod -R u+rw,go-w "$HOME/.config/dwm-titus" 2>/dev/null || true

        # 5. Converter eventuais symlinks read-only do GTK em cópias reais graváveis
        for ini in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini" "$HOME/.gtkrc-2.0"; do
          if [ -L "$ini" ]; then
            target=$($DRY_RUN_CMD readlink -f "$ini" 2>/dev/null || true)
            if [ -n "$target" ] && [ -f "$target" ]; then
              $DRY_RUN_CMD cp --remove-destination "$target" "$ini"
              $DRY_RUN_CMD chmod u+w "$ini" 2>/dev/null || true
            fi
          fi
        done

        # 6. Converter eventuais symlinks read-only do Picom em arquivos reais graváveis
        for pconf in "$HOME/.config/picom/picom.conf" "$HOME/.config/picom.conf"; do
          if [ -L "$pconf" ]; then
            target=$($DRY_RUN_CMD readlink -f "$pconf" 2>/dev/null || true)
            if [ -n "$target" ] && [ -f "$target" ]; then
              $DRY_RUN_CMD cp --remove-destination "$target" "$pconf"
              $DRY_RUN_CMD chmod u+w "$pconf" 2>/dev/null || true
            fi
          fi
        done

        # 7. Inicializar active-theme.toml do Alacritty e kitty se os diretórios existirem
        if [ -d "$HOME/.config/alacritty" ]; then
          if [ -L "$HOME/.config/alacritty/active-theme.toml" ]; then
            $DRY_RUN_CMD rm -f "$HOME/.config/alacritty/active-theme.toml"
          fi
          if [ ! -f "$HOME/.config/alacritty/active-theme.toml" ]; then
            $DRY_RUN_CMD touch "$HOME/.config/alacritty/active-theme.toml"
          fi
          $DRY_RUN_CMD chmod u+w "$HOME/.config/alacritty/active-theme.toml" 2>/dev/null || true
        fi
        if [ -d "$HOME/.config/kitty" ]; then
          if [ -L "$HOME/.config/kitty/active-theme.conf" ]; then
            $DRY_RUN_CMD rm -f "$HOME/.config/kitty/active-theme.conf"
          fi
          if [ ! -f "$HOME/.config/kitty/active-theme.conf" ]; then
            $DRY_RUN_CMD touch "$HOME/.config/kitty/active-theme.conf"
          fi
          $DRY_RUN_CMD chmod u+w "$HOME/.config/kitty/active-theme.conf" 2>/dev/null || true
        fi

        # 8. Garantir permissão de escrita em diretórios qt5ct e qt6ct
        for qtdir in "$HOME/.config/qt5ct" "$HOME/.config/qt6ct"; do
          if [ -d "$qtdir" ]; then
            $DRY_RUN_CMD chmod -R u+w "$qtdir" 2>/dev/null || true
          fi
        done

        # 9. Provisionar diretório ~/Pictures/backgrounds e wallpaper base do NixOS se vazio
        $DRY_RUN_CMD mkdir -p "$HOME/Pictures/backgrounds"
        if [ -z "$($DRY_RUN_CMD ls -A "$HOME/Pictures/backgrounds" 2>/dev/null)" ]; then
          if [ -f "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}" ]; then
            $DRY_RUN_CMD cp -f "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}" "$HOME/Pictures/backgrounds/nixos-wallpaper.png" 2>/dev/null || true
          fi
        fi
      '';
    };
  };
}
