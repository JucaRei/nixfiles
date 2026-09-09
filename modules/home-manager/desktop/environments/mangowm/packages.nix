{
  config,
  lib,
  pkgs,
  inputs,
  desktop ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.desktop.mangowm;

  mangoPkg =
    if (inputs ? mangowm && inputs.mangowm ? packages && inputs.mangowm.packages ? ${pkgs.stdenv.hostPlatform.system}) then
      inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango
    else
      pkgs.emptyDirectory;
in
{
  options.desktop.mangowm = {
    enable = mkOption {
      type = bool;
      default = (desktop == "mangowm" || desktop == "mango");
      description = "Enable MangoWM Wayland dynamic tiling compositor based on dwl";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mangoPkg
      wl-clipboard
      cliphist
      pamixer
      playerctl
      brightnessctl
      libnotify
      grim
      slurp
    ];

    home.file = {
      # Wrapper de inicialização com carregamento do ambiente Nix e drivers gráficos nativos
      ".local/bin/start-mango" = {
        executable = true;
        text = ''
          #!/bin/sh
          # Limpa variáveis herdadas do compositor do Display Manager (ex: Weston no SDDM)
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

          export XDG_CURRENT_DESKTOP=mango
          export XDG_SESSION_DESKTOP=mango
          export XDG_SESSION_TYPE=wayland
          export NIXOS_OZONE_WL=1
          export MOZ_ENABLE_WAYLAND=1
          export _JAVA_AWT_WM_NONREPARENTING=1
          export QT_QPA_PLATFORM="wayland;xcb"
          export GDK_BACKEND="wayland,x11"
          export CLUTTER_BACKEND="wayland"
          export SDL_VIDEODRIVER="wayland"

          # Drivers Mesa nativos para aceleração por hardware em distros não-NixOS
          export GBM_BACKENDS_PATH="${pkgs.mesa}/lib/gbm:/usr/lib64/gbm''${GBM_BACKENDS_PATH:+:$GBM_BACKENDS_PATH}"
          export LIBGL_DRIVERS_PATH="${pkgs.mesa}/lib/dri:/usr/lib64/dri''${LIBGL_DRIVERS_PATH:+:$LIBGL_DRIVERS_PATH}"
          export __EGL_VENDOR_LIBRARY_DIRS="${pkgs.mesa}/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d''${__EGL_VENDOR_LIBRARY_DIRS:+:$__EGL_VENDOR_LIBRARY_DIRS}"

          # Aceleração de hardware VA-API para Intel Sandy Bridge (i965)
          export LIBVA_DRIVER_NAME="i965"
          export LIBVA_DRIVERS_PATH="${pkgs.intel-vaapi-driver}/lib/dri:/usr/lib64/dri''${LIBVA_DRIVERS_PATH:+:$LIBVA_DRIVERS_PATH}"

          # Propagação do ambiente gráfico para o D-Bus e Systemd do usuário
          systemctl --user set-environment GBM_BACKENDS_PATH="$GBM_BACKENDS_PATH" LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" __EGL_VENDOR_LIBRARY_DIRS="$__EGL_VENDOR_LIBRARY_DIRS" LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" LIBVA_DRIVERS_PATH="$LIBVA_DRIVERS_PATH" 2>/dev/null || true
          if command -v dbus-update-activation-environment >/dev/null 2>&1; then
            dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
          fi
          systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE 2>/dev/null || true

          exec ${mangoPkg}/bin/mango "$@"
        '';
      };

      # Entrada de sessão para Display Managers (SDDM, GDM)
      ".local/share/wayland-sessions/mango.desktop".text = ''
        [Desktop Entry]
        Name=Mango
        Comment=Mango Wayland Compositor based on dwl
        Exec=${config.home.homeDirectory}/.local/bin/start-mango
        Type=Application
        DesktopNames=mango
      '';

      # Configuração dos Portals XDG para o Mango
      ".config/xdg-desktop-portal/mango-portals.conf".text = ''
        [preferred]
        default=wlr;gtk
      '';
    };
  };
}
