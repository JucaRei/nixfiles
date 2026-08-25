{
  config,
  lib,
  pkgs,
  useNixGL ? false,
  osConfig ? null,
  username ? "juca",
  ...
}:
let
  inherit (lib) mkOption mkIf optionals;
  inherit (lib.types) bool package;
  cfg = config.desktop.bspwm.packages;

  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);

  isNixOS = osConfig != null;
  homeDir = "/home/${username}";
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

        # Clipboard e X11
        xclip
        xsel
        xdotool
        libnotify
        networkmanagerapplet
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
    };
  };
}
