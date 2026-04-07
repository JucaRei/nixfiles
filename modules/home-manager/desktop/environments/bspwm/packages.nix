{ config, lib, pkgs, useNixGL ? false, osConfig ? null, ... }:
let
  inherit (lib) mkOption mkIf optionals;
  inherit (lib.types) bool package;
  cfg = config.desktop.bspwm.packages;

  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);

  isNixOS = osConfig != null;
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
      xorg.xinit
      xorg.libXcomposite
      xorg.libXinerama
      xorg.xprop
      xorg.libxcb
      xorg.xdpyinfo
      xorg.xkill
      xorg.xsetroot
      xorg.xwininfo
      xorg.xrandr

      # XDG utilities
      xdg-utils
      xdg-user-dirs
      xdg-desktop-portal-gtk

      # Dialog utilities
      dialog
    ] ++ cfg.extraPackages;

    # Create XDG user directories
    xdg.enable = true;

    # Desktop entry for non-NixOS systems
    home.file = mkIf (!isNixOS) {
      ".local/share/xsessions/bspwm.desktop".text = ''
        [Desktop Entry]
        Name=BSPWM
        Comment=Binary space partitioning window manager
        Exec=${pkgs.bspwm}/bin/bspwm
        Type=Application
        DesktopNames=bspwm
      '';
    };
  };
}
