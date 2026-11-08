{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  desktop ? null,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.dwm;

  isNvidiaLegacy = (osConfig.hardware.graphics.cards.gpu or null) == "nvidia-legacy";

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
    enable = lib.my.mkBool (
      desktop == "dwm"
    ) "Enable DWM window manager with custom config.def.h and dwm-titus runtime configuration";

    modifierKey = lib.my.mkStr (config.desktop.modifierKey or "Super"
    ) "Tecla modificadora principal do DWM (Super ou Alt).";

    bar =
      lib.my.mkEnum
        [
          "quickshell"
          "dwm-status"
          "slstatus"
          "polybar"
          "none"
        ]
        "quickshell"
        "Barra de status/painel do DWM. Opções: 'quickshell' (painel moderno do dwm-titus com launcher e control center), 'dwm-status' (script de status nativo do dwm usando xsetroot), 'slstatus', 'polybar' ou 'none'.";

    quickshell = {
      enable = lib.my.mkBool (cfg.bar == "quickshell") "Habilitar Quickshell no DWM";

      qsgBackend =
        lib.my.mkEnum
          [
            "opengl"
            "software"
            "vulkan"
            "auto"
          ]
          (if isNvidiaLegacy then "software" else "opengl")
          "Backend de renderização do Qt Quick Scene Graph (QSG_RHI_BACKEND). No NVIDIA 340 Legacy (sem suporte a Vulkan e com FBConfigs GLX incompatíveis no Qt 6.11), 'software' garante renderização estável via CPU.";

      glIntegration =
        lib.my.mkEnum
          [
            "glx"
            "egl"
            "auto"
            "none"
          ]
          (if isNvidiaLegacy then "none" else "auto")
          "Backend de integração GL do Qt XCB (QT_XCB_GL_INTEGRATION). No NVIDIA 340 Legacy, 'none' previne falhas de contexto dummy GLX/EGL no Qt6.";
    };

    keyboard = {
      brightness = {
        enable = lib.my.mkBool true "Habilitar script dwm-kbd-brightness-osd e atalhos de iluminação do teclado com OSD Dunst";

        device =
          lib.my.mkOpt (lib.types.nullOr lib.types.str) null
            "Dispositivo específico em /sys/class/leds (ex: 'smc::kbd_backlight'), ou null para detecção automática";

        step = lib.my.mkInt 5 "Passo de alteração de brilho do teclado em porcentagem (padrão 5%)";
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
              ${
                lib.optionalString (config.home.keyboard.model != null) "-model '${config.home.keyboard.model}'"
              } \
              ${
                lib.optionalString (config.home.keyboard.layout != null) "-layout '${config.home.keyboard.layout}'"
              } \
              ${
                lib.optionalString (
                  config.home.keyboard.variant != null
                ) "-variant '${config.home.keyboard.variant}'"
              } \
              ${
                lib.concatMapStringsSep " " (opt: "-option '${opt}'") (config.home.keyboard.options or [ ])
              } || true
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
          xsetroot -solid '${config.desktop.theme.colors.bg}' -cursor_name left_ptr &
          if [ -f "$HOME/.fehbg" ]; then
            sh "$HOME/.fehbg" &
          fi

          # 8. Applet de Rede (após importar DISPLAY)
          ${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable &

          # Configurar Touchpad vs Mouse declarativamente:
          # - Touchpad: Natural Scrolling, Tapping, Clickfinger, Perfil de Aceleração e Velocidade do Ponteiro
          # - Mouse: Natural Scrolling DESATIVADO (rolagem padrão tradicional)
          if command -v ${pkgs.xinput}/bin/xinput >/dev/null 2>&1; then
            for id in $(${pkgs.xinput}/bin/xinput list --id-only 2>/dev/null); do
              dev_name=$(${pkgs.xinput}/bin/xinput list --name-only "$id" 2>/dev/null | tr '[:upper:]' '[:lower:]')
              has_tapping=$(${pkgs.xinput}/bin/xinput list-props "$id" 2>/dev/null | grep -c "libinput Tapping Enabled" || true)

              if echo "$dev_name" | grep -q "touchpad" || [ "$has_tapping" -gt 0 ]; then
                ${lib.optionalString config.desktop.touchpad.enable ''
                  ${lib.optionalString config.desktop.touchpad.naturalScrolling ''
                    ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Natural Scrolling Enabled" 1 2>/dev/null || true
                  ''}
                  ${lib.optionalString (!config.desktop.touchpad.naturalScrolling) ''
                    ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Natural Scrolling Enabled" 0 2>/dev/null || true
                  ''}
                  ${lib.optionalString config.desktop.touchpad.tapping ''
                    ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Tapping Enabled" 1 2>/dev/null || true
                  ''}
                  ${lib.optionalString (config.desktop.touchpad.clickMethod == "clickfinger") ''
                    ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Click Method Enabled" 0 1 2>/dev/null || true
                  ''}
                  ${lib.optionalString (config.desktop.touchpad.clickMethod == "buttonareas") ''
                    ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Click Method Enabled" 1 0 2>/dev/null || true
                  ''}
                  ${lib.optionalString (config.desktop.touchpad.accelProfile == "adaptive") ''
                    ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Accel Profile Enabled" 1 0 2>/dev/null || true
                  ''}
                  ${lib.optionalString (config.desktop.touchpad.accelProfile == "flat") ''
                    ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Accel Profile Enabled" 0 1 2>/dev/null || true
                  ''}
                  ${lib.optionalString (config.desktop.touchpad.speed != null) ''
                    ${pkgs.xinput}/bin/xinput set-prop "$id" "libinput Accel Speed" ${toString config.desktop.touchpad.speed} 2>/dev/null || true
                  ''}
                ''}
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
          ${
            if cfg.bar == "quickshell" then
              ''
                pkill -x quickshell || true
                pkill -x slstatus || true
                pkill -x dwm-status || true

                # Iniciar Quickshell com log para diagnóstico (isolando de LD_LIBRARY_PATH e forçando backend de software/none quando configurado)
                env -u LD_LIBRARY_PATH \
                  ${
                    lib.optionalString (
                      cfg.quickshell.qsgBackend == "software"
                    ) "QT_QUICK_BACKEND=software QSG_RHI_BACKEND=software"
                  } \
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
              ''
            else if cfg.bar == "dwm-status" then
              ''
                pkill -x quickshell || true
                pkill -x slstatus || true
                pkill -x dwm-status || true
                ${dwmPackage}/bin/dwm-status &
              ''
            else if cfg.bar == "slstatus" then
              ''
                pkill -x quickshell || true
                pkill -x dwm-status || true
                pkill -x slstatus || true
                ${pkgs.slstatus}/bin/slstatus &
              ''
            else if cfg.bar == "polybar" then
              ''
                pkill -x quickshell || true
                pkill -x dwm-status || true
                pkill -x slstatus || true
                systemctl --user restart polybar 2>/dev/null || true
              ''
            else
              ''
                pkill -x quickshell || true
                pkill -x dwm-status || true
                pkill -x slstatus || true
              ''
          }

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
      }
      // lib.optionalAttrs (cfg.keyboard.brightness.device != null) {
        DWM_KBD_BACKLIGHT_DEVICE = cfg.keyboard.brightness.device;
      };

      # Ativação do Home Manager: provisionar ~/.config/dwm-titus e ~/.config/quickshell como diretórios reais e editáveis
      activation.setupDwmConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        import ./_dwm-activation.nix { inherit pkgs; }
      );
    };
  };
}
