{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkIf optionals;
  cfg = config.desktop.hyprland.packages;
  sets = import ../../packages/sets.nix { inherit pkgs; };

  isNixOS = osConfig != null;
in
{
  options.desktop.hyprland.packages = {
    enable = lib.my.mkBool config.desktop.hyprland.enable "Enable hyprland-related packages";
    extraPackages = lib.my.mkListOf lib.types.package [ ] "Additional packages to include";
  };

  config = mkIf cfg.enable {
    home.packages =
      sets.wayland
      ++ [ (nixGLWrapper pkgs.alacritty) ]
      ++ (with pkgs; [
        polkit_gnome
        wtype
        catppuccin-gtk
        papirus-icon-theme
        catppuccin-cursors.mochaDark
      ])
      ++ optionals (!isNixOS) (
        sets.wayland-standalone
        ++ (with pkgs; [
          xdg-desktop-portal-hyprland
          intel-vaapi-driver
        ])
      )
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
          unset WAYLAND_DISPLAY DISPLAY

          if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          fi
          if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
            . "$HOME/.nix-profile/etc/profile.d/nix.sh"
          fi
          if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
            . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
          fi

          export GBM_BACKENDS_PATH="${pkgs.mesa}/lib/gbm:/usr/lib64/gbm''${GBM_BACKENDS_PATH:+:$GBM_BACKENDS_PATH}"
          export LIBGL_DRIVERS_PATH="${pkgs.mesa}/lib/dri:/usr/lib64/dri''${LIBGL_DRIVERS_PATH:+:$LIBGL_DRIVERS_PATH}"
          export __EGL_VENDOR_LIBRARY_DIRS="${pkgs.mesa}/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d''${__EGL_VENDOR_LIBRARY_DIRS:+:$__EGL_VENDOR_LIBRARY_DIRS}"
          export LIBVA_DRIVER_NAME="i965"
          export LIBVA_DRIVERS_PATH="${pkgs.intel-vaapi-driver}/lib/dri:/usr/lib64/dri''${LIBVA_DRIVERS_PATH:+:$LIBVA_DRIVERS_PATH}"
          export GTK_THEME="catppuccin-mocha-blue-standard+rimless"

          systemctl --user set-environment GBM_BACKENDS_PATH="$GBM_BACKENDS_PATH" LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" __EGL_VENDOR_LIBRARY_DIRS="$__EGL_VENDOR_LIBRARY_DIRS" LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" LIBVA_DRIVERS_PATH="$LIBVA_DRIVERS_PATH" GTK_THEME="$GTK_THEME" 2>/dev/null || true
          unset WLR_BACKEND

          exec ${pkgs.hyprland}/bin/start-hyprland "$@"
        '';
        executable = true;
      };
    };
  };
}
