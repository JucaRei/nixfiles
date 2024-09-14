{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.custom.features.isWayland;
in
{
  options.custom.features.isWayland = {
    enable = mkEnableOption "Wayland configuration management for user";
    session-type = mkOption {
      description = "An option to choose the window manager or desktop [wayland] configuration to enable";
      default = [ "gnome" ];
      type = with types; oneOf (enum [ "sway" "hyprland" "gnome" "cinnamon" "" ]);
      example = [ "sway" ];
    };

    config = mkIf cfg.enable {
      home.sessionVariables = {
        GDK_BACKEND = "wayland,x11";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        MOZ_ENABLE_WAYLAND = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        NIXOS_OZONE_WL = "1";
        # GTK_USE_PORTAL = "1";
        # WLR_RENDERER_ALLOW_SOFTWARE = "1";
      };
    };
  };
}
