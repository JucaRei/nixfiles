{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.file-managers.nautilus;
in
{
  options = {
    desktop.apps.file-managers.nautilus = {
      enable = mkEnableOption "Enable and set nautilus as default file-manager.";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs // pkgs.gnome;[
        nautilus
        gvfs
        sushi
        nautilus-open-any-terminal
      ];

      # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features

      sessionVariables = {
        GIO_EXTRA_MODULES = "${pkgs.gnome.gvfs}/lib/gio/modules";
      };
    };
  };
}
