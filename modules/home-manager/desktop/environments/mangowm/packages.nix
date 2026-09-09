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
          if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          fi
          if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
            . "$HOME/.nix-profile/etc/profile.d/nix.sh"
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
          export GBM_BACKENDS_PATH="/usr/lib64/gbm:/usr/lib/x86_64-linux-gnu/gbm:$GBM_BACKENDS_PATH"
          export LIBGL_DRIVERS_PATH="/usr/lib64/dri:/usr/lib/x86_64-linux-gnu/dri:$LIBGL_DRIVERS_PATH"

          # Propagação do ambiente gráfico para o D-Bus e Systemd do usuário
          dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
          systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE

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
