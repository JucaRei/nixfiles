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

    # Sessão Wayland e wrapper para sistemas não-NixOS (Fedora/standalone)
    home.file = mkIf (!isNixOS) {
      ".local/share/wayland-sessions/hyprland.desktop".text = ''
        [Desktop Entry]
        Name=Hyprland
        Comment=An intelligent dynamic tiling Wayland compositor
        Exec=${config.home.homeDirectory}/.local/bin/start-hyprland
        Type=Application
        DesktopNames=Hyprland
      '';

      ".local/bin/start-hyprland" = {
        text = ''
          #!/bin/sh
          # Limpa variáveis herdadas do compositor do Display Manager (ex: Weston no SDDM)
          # para que o Aquamarine acesse diretamente o backend DRM no hardware
          unset WAYLAND_DISPLAY
          unset DISPLAY

          if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          fi
          if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
            . "$HOME/.nix-profile/etc/profile.d/nix.sh"
          fi
          if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
            . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
          fi

          # Suporte a drivers gráficos Mesa e GBM em distribuições não-NixOS (Fedora standalone)
          # Garante que libgbm e Aquamarine encontrem dri_gbm.so sem falhar na busca de /run/opengl-driver
          export GBM_BACKENDS_PATH="${pkgs.mesa}/lib/gbm:/usr/lib64/gbm''${GBM_BACKENDS_PATH:+:$GBM_BACKENDS_PATH}"
          export LIBGL_DRIVERS_PATH="${pkgs.mesa}/lib/dri:/usr/lib64/dri''${LIBGL_DRIVERS_PATH:+:$LIBGL_DRIVERS_PATH}"
          export __EGL_VENDOR_LIBRARY_DIRS="${pkgs.mesa}/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d''${__EGL_VENDOR_LIBRARY_DIRS:+:$__EGL_VENDOR_LIBRARY_DIRS}"

          # Evita tentativa de carregar backend Vulkan inexistente no Intel Sandy Bridge (HD 3000)
          unset WLR_BACKEND

          exec ${pkgs.hyprland}/bin/Hyprland "$@"
        '';
        executable = true;
      };
    };
  };
}
