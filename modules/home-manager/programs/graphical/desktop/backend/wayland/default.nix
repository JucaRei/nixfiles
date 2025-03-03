{ config, lib, desktop, osConfig, ... }:
let
  inherit (lib) mkIf;
  backend = config.programs.graphical.desktop.backend;
  # hm-backend = osConfig.config.programs.graphical.desktop.backend;
in
{
  # config = mkIf (backend == "wayland") || (hm-backend == "wayland") {
  config = mkIf (backend == "wayland") {
    home = {
      sessionVariables = {
        GDK_BACKEND = "wayland,x11";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland";
        QT_QPA_PLATFORM = "wayland;xcb";
        LIBSEAT_BACKEND = "logind";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        # MOZ_ENABLE_WAYLAND = mkIf (lib.package.firefox) "1";
        NIXOS_OZONE_WL = "1";
        GTK_USE_PORTAL = "1";
        WLR_RENDERER_ALLOW_SOFTWARE = "1";
        # ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };
    };
  };
}
