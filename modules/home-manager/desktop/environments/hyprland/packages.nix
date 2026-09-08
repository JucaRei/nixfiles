{
  config,
  lib,
  pkgs,
  useNixGL ? false,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf optionals;
  inherit (lib.types) bool package listOf;
  cfg = config.desktop.hyprland.packages;

  nixGL = import ../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);

  isNixOS = osConfig != null;
in
{
  options.desktop.hyprland.packages = {
    enable = mkOption {
      type = bool;
      default = config.desktop.hyprland.enable;
      description = "Enable hyprland-related packages";
    };

    extraPackages = mkOption {
      type = listOf package;
      default = [ ];
      description = "Additional packages to include";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        # Terminal e utilitários
        (nixGLWrapper alacritty)

        # Captura de tela e Clipboard
        grim
        slurp
        wl-clipboard
        cliphist
        swappy

        # Áudio, Brilho e Mídia
        pavucontrol
        pamixer
        playerctl
        brightnessctl

        # Polkit e Notificações
        polkit_gnome
        libnotify

        # Utilitários Desktop e Aparência
        networkmanagerapplet
        galculator
        wtype
        xdg-utils

        # Temas e Fontes
        catppuccin-gtk
        papirus-icon-theme
        catppuccin-cursors.mochaDark
        inter
      ]
      ++ optionals (!isNixOS) [
        glibcLocales
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ]
      ++ cfg.extraPackages;

    xdg.enable = true;

    # Sessão Wayland para gerenciadores de login (ex: GDM, SDDM, Regreet) em sistemas não-NixOS
    home.file = mkIf (!isNixOS) {
      ".local/share/wayland-sessions/hyprland.desktop".text = ''
        [Desktop Entry]
        Name=Hyprland
        Comment=An intelligent dynamic tiling Wayland compositor
        Exec=${pkgs.hyprland}/bin/Hyprland
        Type=Application
        DesktopNames=Hyprland
      '';
    };
  };
}
