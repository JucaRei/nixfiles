{
  config,
  lib,
  pkgs,
  useNixGL ? false,
  osConfig ? null,
  username ? "juca",
  nixGLType ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf optionals;
  inherit (lib.types) bool package;
  cfg = config.desktop.bspwm.packages;

  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs nixGLType; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);

  isNixOS = osConfig != null;
  homeDir = "/home/${username}";

  # Bin do alacritty com nixGL wrapper
  alacrittyBin =
    if useNixGL then
      "${nixGL.wrapper pkgs.alacritty}/bin/alacritty"
    else
      "${pkgs.alacritty}/bin/alacritty";

  # Script utilitário para consulta e alteração dinâmica da velocidade do touchpad via CLI ou atalho
  touchpadSpeedScript = pkgs.writeShellScriptBin "touchpad-speed" ''
    export PATH="${lib.makeBinPath [ pkgs.xinput pkgs.gnugrep pkgs.gawk pkgs.gnused pkgs.coreutils pkgs.dunst ]}:$PATH"
    NEW_SPEED="$1"

    COUNT=0
    for id in $(xinput list --id-only 2>/dev/null); do
      dev_name=$(xinput list --name-only "$id" 2>/dev/null | tr '[:upper:]' '[:lower:]')
      has_tapping=$(xinput list-props "$id" 2>/dev/null | grep -c "libinput Tapping Enabled" || true)

      if echo "$dev_name" | grep -q "touchpad" || [ "$has_tapping" -gt 0 ]; then
        real_name=$(xinput list --name-only "$id" 2>/dev/null)
        curr_speed=$(xinput list-props "$id" 2>/dev/null | grep "libinput Accel Speed (" | awk -F':' '{print $2}' | tr -d ' \t')

        if [ -n "$NEW_SPEED" ]; then
          if xinput set-prop "$id" "libinput Accel Speed" "$NEW_SPEED" 2>/dev/null; then
            echo "✓ Touchpad [$id: $real_name]: velocidade alterada de $curr_speed para $NEW_SPEED"
            COUNT=$((COUNT + 1))
          else
            echo "✗ Falha ao definir velocidade para [$id: $real_name]" >&2
          fi
        else
          echo "ℹ Touchpad [$id: $real_name]: velocidade atual = $curr_speed"
          COUNT=$((COUNT + 1))
        fi
      fi
    done

    if [ "$COUNT" -eq 0 ]; then
      echo "Nenhum touchpad compatível com libinput encontrado via xinput." >&2
      exit 1
    fi

    if [ -n "$NEW_SPEED" ]; then
      dunstify -a "Touchpad" -u low -i "input-touchpad" -r 9991 -t 2000 "Velocidade do Touchpad" "Nova velocidade: $NEW_SPEED (-1.0 a 1.0)" 2>/dev/null || true
    fi
  '';
in
{
  options.desktop.bspwm.packages = {
    enable = mkOption {
      type = bool;
      default = config.desktop.bspwm.enable;
      description = "Enable bspwm-related packages";
    };

    extraPackages = mkOption {
      type = lib.types.listOf package;
      default = [ ];
      description = "Additional packages to include";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        # Utilitários e Desktop
        feh
        (nixGLWrapper alacritty)
        touchpadSpeedScript
        (pkgs.writeShellScriptBin "bspwm-touchpad-speed" ''exec ${touchpadSpeedScript}/bin/touchpad-speed "$@"'')

        # Áudio e Brilho
        pavucontrol
        pamixer
        playerctl
        brightnessctl

        # Temas e Fontes
        catppuccin-gtk
        papirus-icon-theme
        catppuccin-cursors.mochaDark
        inter
        noto-fonts-cjk-sans
        ipafont

        # Clipboard, Captura de Tela e X11 (Estilo gh0stzk)
        xclip
        xsel
        xdotool
        libnotify
        maim
        slop
        xcolor
        jq
        networkmanagerapplet
        blueman
        pasystray
        galculator
        lxappearance
      ]
      ++ optionals (!isNixOS) [
        glibcLocales
        at-spi2-atk
        xinit
        libxcomposite
        libxinerama
        xprop
        libxcb
        xdpyinfo
        xkill
        xsetroot
        xrdb
        xwininfo
        xrandr
        xdg-utils
        xdg-user-dirs
        xdg-desktop-portal-gtk
        dialog
      ]
      ++ cfg.extraPackages;

    xdg.enable = true;

    # Sessão para LightDM em sistemas não-NixOS
    home.file = mkIf (!isNixOS) {
      ".local/share/xsessions/bspwm.desktop".text = ''
        [Desktop Entry]
        Name=BSPWM
        Comment=Binary space partitioning window manager
        Exec=${homeDir}/.local/bin/start-bspwm
        Type=Application
        DesktopNames=bspwm
      '';

      ".local/bin/start-bspwm".text = ''
        #!/bin/sh
        if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
        if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
        exec "$HOME/.xsession"
      '';
      ".local/bin/start-bspwm".executable = true;

      ".dmrc".text = ''
        [Desktop]
        Session=bspwm
      '';

      # -----------------------------------------------------------------------
      # Arquivos .desktop para apps Nix (necessário em distros não-NixOS onde
      # o menu gráfico não lê automaticamente XDG_DATA_DIRS do Nix Store)
      # -----------------------------------------------------------------------

      # Alacritty com nixGL wrapper no Exec (corrige erro GL em Debian/Fedora)
      # Nota: nome em maiúsculo "Alacritty.desktop" é essencial para sobrepor (shadow) o .desktop upstream do Nix Store sem duplicar
      ".local/share/applications/Alacritty.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Alacritty
        GenericName=Terminal
        Comment=A fast, cross-platform, OpenGL terminal emulator
        Exec=${alacrittyBin} %U
        Icon=Alacritty
        Terminal=false
        Categories=System;TerminalEmulator;
        Keywords=terminal;shell;
        StartupWMClass=Alacritty
        StartupNotify=false
        Actions=New;Float;

        [Desktop Action New]
        Name=New Terminal Window
        Exec=${alacrittyBin}

        [Desktop Action Float]
        Name=New Floating Terminal
        Exec=${alacrittyBin} --class AlacrittyFloat
      '';

      # Pavucontrol
      ".local/share/applications/pavucontrol.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=PulseAudio Volume Control
        GenericName=Volume Control
        Comment=Adjust volume levels for PulseAudio/PipeWire
        Exec=${pkgs.pavucontrol}/bin/pavucontrol
        Icon=multimedia-volume-control
        Terminal=false
        Categories=AudioVideo;Audio;Mixer;
        Keywords=audio;volume;sound;pulseaudio;pipewire;
      '';

      # Galculator
      ".local/share/applications/galculator.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Galculator
        Comment=GTK+ based scientific calculator
        Exec=${pkgs.galculator}/bin/galculator
        Icon=galculator
        Terminal=false
        Categories=GNOME;GTK;Utility;
        Keywords=calculator;math;
      '';

      # LXAppearance
      ".local/share/applications/lxappearance.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Customize Look and Feel
        GenericName=Theme switcher
        Comment=GTK+ theme switcher for LXDE
        Exec=${pkgs.lxappearance}/bin/lxappearance
        Icon=preferences-desktop-theme
        Terminal=false
        Categories=Settings;DesktopSettings;
        Keywords=theme;gtk;appearance;
      '';

      # Feh (Visualizador de imagens)
      ".local/share/applications/feh.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Feh
        GenericName=Image Viewer
        Comment=Fast and light image viewer
        Exec=${pkgs.feh}/bin/feh --scale-down --auto-zoom %f
        Icon=feh
        Terminal=false
        Categories=Graphics;Viewer;
        MimeType=image/bmp;image/gif;image/jpeg;image/png;image/svg+xml;image/tiff;image/webp;
        Keywords=image;photo;viewer;
      '';
    };

    # -------------------------------------------------------------------------
    # Ativação pós-switch: atualizar banco de dados de apps desktop
    # Garante que o menu gráfico (Rofi, XFCE, etc.) veja os .desktop do Nix Store
    # e os novos .desktop criados acima em ~/.local/share/applications/
    # -------------------------------------------------------------------------
    home.activation.updateDesktopDatabase = lib.mkIf (!isNixOS) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Remove arquivo .desktop em minúsculo antigo para prevenir duplicação no Rofi
      rm -f "$HOME/.local/share/applications/alacritty.desktop"
    '');
  };
}
