{
  config,
  lib,
  pkgs,
  useNixGL ? false,
  nixGLWrapper ? lib.id,
  osConfig ? null,
  username ? "juca",
  ...
}:
let
  inherit (lib) mkIf optionals;
  cfg = config.desktop.bspwm.packages;
  sets = import ../../packages/sets.nix { inherit pkgs; };

  isNixOS = osConfig != null;
  homeDir = "/home/${username}";

  alacrittyBin =
    if useNixGL then
      "${nixGLWrapper pkgs.alacritty}/bin/alacritty"
    else
      "${pkgs.alacritty}/bin/alacritty";

  touchpadSpeedScript = pkgs.writeShellApplication {
    name = "touchpad-speed";
    runtimeInputs = with pkgs; [
      xinput
      gnugrep
      gawk
      gnused
      coreutils
      dunst
    ];
    text = builtins.readFile ./scripts/touchpad-speed.sh;
  };

  portalConf = ''
    [preferred]
    default=gtk
    org.freedesktop.impl.portal.FileChooser=gtk
    org.freedesktop.impl.portal.AppChooser=gtk
    org.freedesktop.impl.portal.OpenURI=gtk
  '';
in
{
  options.desktop.bspwm.packages = {
    enable = lib.my.mkBool config.desktop.bspwm.enable "Enable bspwm-related packages";
    extraPackages = lib.my.mkListOf lib.types.package [ ] "Additional packages to include";
  };

  config = mkIf cfg.enable {
    home = {
      packages =
        sets.x11
        ++ (with pkgs; [
          touchpadSpeedScript
          (pkgs.writeShellScriptBin "bspwm-touchpad-speed" ''exec ${touchpadSpeedScript}/bin/touchpad-speed "$@"'')
          bsp-layout
          blueman
          pasystray
          lxappearance
        ])
        ++ optionals ((config.system.programs.terminal.name or "") == "alacritty") [
          (nixGLWrapper pkgs.alacritty)
        ]
        ++ optionals (!isNixOS) sets.x11-standalone
        ++ cfg.extraPackages;

      # Sessão para LightDM em sistemas não-NixOS
      file = mkIf (!isNixOS) {
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
          if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
            . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
          fi

          export XDG_CURRENT_DESKTOP=bspwm XDG_SESSION_DESKTOP=bspwm XDG_SESSION_TYPE=x11
          exec "$HOME/.xsession"
        '';
        ".local/bin/start-bspwm".executable = true;

        ".dmrc".text = ''
          [Desktop]
          Session=bspwm
        '';

        # Arquivos .desktop para apps Nix (necessário em distros não-NixOS onde o menu gráfico não lê Nix Store)
        ".local/share/applications/Alacritty.desktop" =
          lib.mkIf ((config.system.programs.terminal.name or "") == "alacritty")
            {
              text = ''
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
            };

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

      activation.updateDesktopDatabase = lib.mkIf (!isNixOS) (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          rm -f "$HOME/.local/share/applications/alacritty.desktop"
        ''
      );
    };

    xdg = {
      enable = true;
      configFile = {
        "xdg-desktop-portal/bspwm-portals.conf".text = portalConf;
        "xdg-desktop-portal/portals.conf".text = portalConf;
      };
    };
  };
}
