{ config, lib, osConfig ? null, ... }:
let
  cfg = config.desktop.display-servers;
  inherit (lib) mkDefault mkIf;
  # isNixos = builtins.hasAttr "system" config; # only present on NixOS systems
  isNixOS = osConfig != null;
in
{
  config = mkIf (cfg.backend == "wayland" && !isNixos) {
    home = {
      sessionVariables = {
        QT_QPA_PLATFORM = "wayland;xcb";
        XDG_SESSION_TYPE = "wayland";
        WLR_BACKEND = "vulkan";
        EGL_PLATFORM = "wayland";
      };
    };
  };
}
