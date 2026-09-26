{
  config,
  lib,
  pkgs,
  useNixGL ? false,
  desktop ? null,
  nixGLType ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool str;
  cfg = config.desktop.dwm;

  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs nixGLType; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);

  # DWM construído a partir do código-fonte e C configs da pasta ./configs
  dwmPackage = pkgs.stdenv.mkDerivation {
    pname = "dwm-titus";
    version = "0.7.2";

    src = ./configs;

    nativeBuildInputs = [
      pkgs.pkg-config
    ];

    # Dependências declaradas no repositório (config.mk / PKG_MODULES)
    buildInputs = with pkgs; [
      xorg.libX11
      xorg.libXft
      xorg.libXinerama
      xorg.libXrender
      xorg.libXcursor
      xorg.libxcb
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
  };
in
{
  options.desktop.dwm = {
    enable = mkOption {
      type = bool;
      default = (desktop == "dwm");
      description = "Enable DWM window manager with custom config.def.h";
    };

    modifierKey = mkOption {
      type = str;
      default = config.desktop.modifierKey or "Super";
      description = "Tecla modificadora principal do DWM.";
    };
  };

  config = mkIf cfg.enable {
    # Arquivos de configuração em tempo de execução do DWM (hotkeys, temas e regras de janelas)
    xdg.configFile."dwm-titus".source = ./configs/config;

    xsession = {
      enable = true;
      windowManager = {
        command = ''
          # 1. Configuração do teclado herdada declarativamente de home.keyboard
          ${lib.optionalString (config.home.keyboard != null) ''
            ${pkgs.xorg.setxkbmap}/bin/setxkbmap \
              ${lib.optionalString (config.home.keyboard.model != null) "-model '${config.home.keyboard.model}'"} \
              ${lib.optionalString (config.home.keyboard.layout != null) "-layout '${config.home.keyboard.layout}'"} \
              ${lib.optionalString (config.home.keyboard.variant != null) "-variant '${config.home.keyboard.variant}'"} \
              ${lib.concatMapStringsSep " " (opt: "-option '${opt}'") (config.home.keyboard.options or [ ])} || true
          ''}

          # 2. Carregar bibliotecas de driver gráfico se presentes (ex: NVIDIA 340 no NixOS / Debian)
          if [ -d /run/opengl-driver/lib ] && [ -f /run/opengl-driver/lib/libGL.so.1 ]; then
            export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          fi

          # 3. Carregar recursos do X11 (incluindo tema e tamanho de cursor Xcursor)
          [ -f "$HOME/.Xresources" ] && ${pkgs.xorg.xrdb}/bin/xrdb -merge "$HOME/.Xresources" || true

          # 4. Importar variáveis de ambiente para serviços do usuário
          systemctl --user import-environment DISPLAY XAUTHORITY LD_LIBRARY_PATH LIBVA_DRIVER_NAME VDPAU_DRIVER XCURSOR_THEME XCURSOR_SIZE
          systemctl --user start graphical-session.target 2>/dev/null || true

          # 5. Agente de autenticação Polkit (Agnóstico de distro)
          ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &

          # 6. Wallpaper / Fundo e Cursor padrão (gerenciado via feh)
          xsetroot -solid '#1e1e2e' -cursor_name left_ptr &
          if [ -f "$HOME/.fehbg" ]; then
            sh "$HOME/.fehbg" &
          fi

          # 7. Applet de Rede (após importar DISPLAY)
          ${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable &

          # 8. Configurar Touchpad vs Mouse:
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

          # 9. Iniciar compositor Picom se habilitado
          ${lib.optionalString config.desktop.dwm.picom.enable ''
            pkill -x picom || true
            systemctl --user restart picom 2>/dev/null || (${pkgs.picom}/bin/picom -b 2>/dev/null || true) &
          ''}

          # 10. Iniciar barra de status slstatus se presente
          if command -v ${pkgs.slstatus}/bin/slstatus >/dev/null 2>&1; then
            pkill -x slstatus || true
            ${pkgs.slstatus}/bin/slstatus &
          fi

          # 11. Executar DWM com nixGL wrapper (para suporte a distros standalone como Fedora/Debian)
          exec ${nixGLWrapper dwmPackage}/bin/dwm
        '';
      };
    };

    home = {
      packages = [
        (nixGLWrapper dwmPackage)
        pkgs.slstatus
        pkgs.polkit_gnome
        pkgs.networkmanagerapplet
        pkgs.xinput
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
      };
    };
  };
}
