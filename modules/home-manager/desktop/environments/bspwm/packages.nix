{ config, lib, pkgs, useNixGL ? false, osConfig ? null, username ? "juca", ... }:
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
      default = true;
      description = "Enable bspwm-related packages";
    };

    extraPackages = mkOption {
      type = lib.types.listOf package;
      default = [ ];
      description = "Additional packages to include";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Window Manager
      sxhkd

      # Launcher
      rofi

      # Terminal
      (nixGLWrapper alacritty)

      # Screenshot
      flameshot

      # Audio control
      pavucontrol
      playerctl
      brightnessctl

      # Utilities
      xclip
      bc
      imagemagick

      # System utilities (non-NixOS)
    ] ++ optionals (!isNixOS) [
      glibcLocales
      at-spi2-atk

      # X11 utilities
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

      # XDG utilities
      xdg-utils
      xdg-user-dirs
      xdg-desktop-portal-gtk

      # Dialog utilities
      dialog
    ] ++ cfg.extraPackages;

    # Create XDG user directories
    xdg.enable = true;

    # Desktop entry and wrapper for non-NixOS systems (LightDM compatibility)
    home.file = mkIf (!isNixOS) {
      # xsessions desktop entry for LightDM
      ".local/share/xsessions/bspwm.desktop".text = ''
        [Desktop Entry]
        Name=BSPWM
        Comment=Binary space partitioning window manager
        Exec=${homeDir}/.local/bin/start-bspwm
        Type=Application
        DesktopNames=bspwm
      '';

      # Wrapper: source nix env, then let .xsession handle the rest
      ".local/bin/start-bspwm".text = ''
        #!/bin/sh
        
        # Source nix profile (Fedora's LightDM won't have it)
        if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
        if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
        
        # Let home-manager's .xsession handle the rest (it sources .xprofile internally)
        exec "$HOME/.xsession"
      '';
      ".local/bin/start-bspwm".executable = true;

      # Tell LightDM to use bspwm as default session
      ".dmrc".text = ''
        [Desktop]
        Session=bspwm
      '';
    };
  };
}

# sudo sed -i 's|#sessions-directory=.*|sessions-directory=/usr/share/xsessions:/usr/share/wayland-sessions:/home/juca/.local/share/xsessions|' /etc/lightdm/lightdm.conf