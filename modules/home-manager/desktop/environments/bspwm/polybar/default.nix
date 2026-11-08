# What it is: Polybar status bar configuration for BSPWM.
# How to enable: Set `desktop.bspwm.polybar.enable = true;`.
# Example: desktop.bspwm.polybar.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.bspwm.polybar;

  colors = import ./colors.nix { theme = config.desktop.theme; };
  polybarPkg = pkgs.polybar.override {
    pulseSupport = true;
    i3Support = false;
  };
  scripts = import ./scripts.nix {
    inherit pkgs colors;
    polybar = polybarPkg;
  };
  polybarModules = import ./modules.nix {
    inherit
      lib
      pkgs
      colors
      scripts
      cfg
      ;
  };

in
{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    home = {
      packages = [
        polybarPkg
        scripts.rofiBluetoothMenuPkg
        (pkgs.writeShellScriptBin "bspwm-bluetooth" ''exec ${scripts.rofiBluetoothMenu} "$@"'')
        scripts.rofiWifiMenuPkg
        (pkgs.writeShellScriptBin "bspwm-wifi" ''exec ${scripts.rofiWifiMenu} "$@"'')
        scripts.rofiLayoutMenuPkg
        scripts.bspLayoutSwitchScriptPkg
        scripts.osLogoScriptPkg
        scripts.polybarLaunchScriptPkg
        scripts.mediaControlScriptPkg
        scripts.rofiNotificationMenuPkg
        scripts.notificationStatusScriptPkg
        (pkgs.writeShellScriptBin "polybar-notifications" ''exec ${scripts.notificationStatusScript} "$@"'')
      ]
      ++ lib.optionals cfg.tray.enable [
        pkgs.stalonetray
        scripts.stalonetrayToggleScriptPkg
      ];

      # Recarregar automaticamente o Stalonetray ao rodar switch-home se habilitado
      activation.reloadStalonetray = mkIf (cfg.tray.enable && config.services.stalonetray.enable) (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if systemctl --user is-active --quiet stalonetray.service 2>/dev/null; then
            $DRY_RUN_CMD systemctl --user restart stalonetray.service 2>/dev/null || true
          elif ${pkgs.procps}/bin/pgrep -x stalonetray >/dev/null 2>&1; then
            $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -x stalonetray 2>/dev/null || true
            $DRY_RUN_CMD nohup ${pkgs.stalonetray}/bin/stalonetray >/dev/null 2>&1 &
          fi
        ''
      );

      # Recarregar automaticamente a Polybar ao rodar switch-home
      activation.reloadPolybar = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if command -v polybar-launch >/dev/null 2>&1; then
          $DRY_RUN_CMD polybar-launch 2>/dev/null || true
        else
          $DRY_RUN_CMD ${polybarPkg}/bin/polybar-msg cmd restart 2>/dev/null || true
        fi
      '';
    };

    services = {
      # Serviços do Stalonetray (apenas se bandeja habilitada na Polybar)
      stalonetray = mkIf cfg.tray.enable {
        enable = true;
        package = pkgs.stalonetray;
        config = {
          background = colors.surface;
          decorations = "none";
          dockapp_mode = "none";
          geometry = "5x1-16+44";
          max_geometry = "8x1-16+44";
          grow_gravity = "NW";
          icon_gravity = "NE";
          icon_size = 20;
          slot_size = 24;
          sticky = true;
          skip_taskbar = true;
          window_type = "dock";
          window_layer = "top";
          kludges = "force_icons_size";
        };
      };

      polybar = {
        enable = true;
        package = polybarPkg;
        script = ''
          exec ${scripts.polybarLaunchScript}
        '';
        config = import ./_config.nix {
          inherit
            lib
            cfg
            colors
            polybarModules
            ;
        };
      };
    };
  };
}
