{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.custom.features.isWayland;
in
{
  options.custom.features.isWayland = {
    enable = mkEnableOption "wayland configuration management for user";
    wm = mkOption {
      description = "An option to choose the window manager [wayland] configuration to enable";
      default = [ "hyprland" ];
      type = with types; listOf (enum [ "sway" "hyprland" "" ]);
      example = [ "sway" ];
    };
    desktop = mkOption {
      description = "If you using a desktop environment with wayland";
      default = null;
      type = with types; listOf (enum [ "gnome" "cinnamon" "" ]);
      example = [ "sway" ];
    };

    config = mkIf cfg.enable {
      home.sessionVariables = {
        GDK_BACKEND = "wayland,x11";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland";
        # GTK_USE_PORTAL = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        MOZ_ENABLE_WAYLAND = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        NIXOS_OZONE_WL = "1";
        # WLR_RENDERER_ALLOW_SOFTWARE = "1";
      };
    };
  };
}
