{ pkgs, lib, config, osConfig ? null, nixGLWrapper, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.apps.graphical.file-manager.nautilus;

  isNixOS = osConfig != null;

  packagess = with pkgs // pkgs.gnome;[
    nautilus
    gvfs
    sushi
    nautilus-open-any-terminal
  ];
in
{
  options = {
    apps.graphical.file-manager.nautilus = {
      enable = mkEnableOption "Enable and set nautilus as default file-manager.";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = if (isNixOS) then nixGLWrapper packagess else packagess;

      # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features

      sessionVariables = {
        GIO_EXTRA_MODULES = "${pkgs.gnome.gvfs}/lib/gio/modules";
      };
    };
  };
}
