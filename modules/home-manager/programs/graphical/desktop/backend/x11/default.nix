{ config, lib, desktop, ... }:
let
  inherit (lib) mkIf;
  backend = config.programs.graphical.desktop.backend;
in
{
  config = mkIf (backend == "x11") {
    home = {
      sessionVariables = {
        XDG_SESSION_TYPE = "x11";
        GDK_BACKEND = "x11";
        SDL_VIDEODRIVER = "x11";
        _JAVA_AWT_WM_NONREPARENTING = mkIf (desktop == "bspwm") "1";
        SDL_AUDIO_DRIVER = "pipewire,pulseaudio,dsound";
      };
    };
  };
}
