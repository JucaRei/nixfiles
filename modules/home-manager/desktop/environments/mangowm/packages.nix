{
  config,
  lib,
  pkgs,
  inputs,
  desktop ? null,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.mangowm;
  c = config.desktop.theme.colors;
  sets = import ../../packages/sets.nix { inherit pkgs; };

  mangoPkg =
    if
      (
        inputs ? mangowm
        && inputs.mangowm ? packages
        && inputs.mangowm.packages ? ${pkgs.stdenv.hostPlatform.system}
      )
    then
      inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango
    else
      pkgs.emptyDirectory;

  mangoReload = pkgs.writeShellApplication {
    name = "mango-reload";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
    ];
    text = builtins.readFile ./scripts/mango-reload.sh;
  };

  mangoToggleOuterGaps = pkgs.writeShellApplication {
    name = "mango-toggle-outer-gaps";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
    ];
    text = builtins.readFile ./scripts/mango-toggle-outer-gaps.sh;
  };

  mangoLayoutSwitcher = pkgs.writeShellApplication {
    name = "mango-layout-switcher";
    runtimeInputs = with pkgs; [
      coreutils
      jq
    ];
    text = builtins.readFile ./scripts/mango-layout-switcher.sh;
  };

  mangoLayoutPicker = pkgs.writeShellScriptBin "mango-layout-picker" (
    builtins.replaceStrings
      [
        "@BG@"
        "@BG_ALT@"
        "@ACCENT@"
        "@SURFACE@"
        "@FG@"
        "@FG_MUTED@"
        "@BG_DARK@"
      ]
      [
        c.bg
        c.bgAlt
        c.accent
        c.surface
        c.fg
        c.fgMuted
        c.bgDark
      ]
      (builtins.readFile ./scripts/mango-layout-picker.sh)
  );
in
{
  options.desktop.mangowm = {
    enable = lib.my.mkBool (
      desktop == "mangowm" || desktop == "mango"
    ) "Enable MangoWM Wayland dynamic tiling compositor based on dwl";

    monitorRules =
      lib.my.mkListOf lib.types.str [ ]
        "List of monitor rules for MangoWM (e.g. 'name:eDP-1,width:1366,height:768,refresh:60,scale:1')";

    modifierKey = lib.my.mkStr (config.desktop.modifierKey or "Super"
    ) "Tecla modificadora principal do MangoWM (ex: 'SUPER', 'ALT', 'CTRL').";
  };

  config = mkIf cfg.enable {
    home.packages =
      sets.wayland
      ++ (with pkgs; [
        mangoPkg
        mangoReload
        mangoToggleOuterGaps
        mangoLayoutSwitcher
        mangoLayoutPicker
        hicolor-icon-theme
        adwaita-icon-theme
      ]);

    home.file = {
      ".local/bin/start-mango" = {
        executable = true;
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

          export XDG_CURRENT_DESKTOP=mango XDG_SESSION_DESKTOP=mango XDG_SESSION_TYPE=wayland
          export NIXOS_OZONE_WL=1 MOZ_ENABLE_WAYLAND=1 _JAVA_AWT_WM_NONREPARENTING=1
          export QT_QPA_PLATFORM="wayland;xcb" GDK_BACKEND="wayland,x11" CLUTTER_BACKEND="wayland" SDL_VIDEODRIVER="wayland"
          export GTK_THEME="catppuccin-mocha-blue-standard+rimless"

          export GBM_BACKENDS_PATH="${pkgs.mesa}/lib/gbm:/usr/lib64/gbm''${GBM_BACKENDS_PATH:+:$GBM_BACKENDS_PATH}"
          export LIBGL_DRIVERS_PATH="${pkgs.mesa}/lib/dri:/usr/lib64/dri''${LIBGL_DRIVERS_PATH:+:$LIBGL_DRIVERS_PATH}"
          export __EGL_VENDOR_LIBRARY_DIRS="${pkgs.mesa}/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d''${__EGL_VENDOR_LIBRARY_DIRS:+:$__EGL_VENDOR_LIBRARY_DIRS}"
          export LIBVA_DRIVER_NAME="i965"
          export LIBVA_DRIVERS_PATH="${pkgs.intel-vaapi-driver}/lib/dri:/usr/lib64/dri''${LIBVA_DRIVERS_PATH:+:$LIBVA_DRIVERS_PATH}"

          systemctl --user set-environment GBM_BACKENDS_PATH="$GBM_BACKENDS_PATH" LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" __EGL_VENDOR_LIBRARY_DIRS="$__EGL_VENDOR_LIBRARY_DIRS" LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" LIBVA_DRIVERS_PATH="$LIBVA_DRIVERS_PATH" GTK_THEME="$GTK_THEME" 2>/dev/null || true
          if command -v dbus-update-activation-environment >/dev/null 2>&1; then
            dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE GTK_THEME
          fi
          systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE GTK_THEME 2>/dev/null || true

          exec ${mangoPkg}/bin/mango "$@"
        '';
      };

      ".local/share/wayland-sessions/mango.desktop".text = ''
        [Desktop Entry]
        Name=Mango
        Comment=Mango Wayland Compositor based on dwl
        Exec=${config.home.homeDirectory}/.local/bin/start-mango
        Type=Application
        DesktopNames=mango
      '';

      ".config/xdg-desktop-portal/mango-portals.conf".text = ''
        [preferred]
        default=wlr;gtk
      '';
    };
  };
}
