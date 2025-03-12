{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.programs.graphical.apps.file-manager.nautilus;
in
{
  options = {
    programs.graphical.apps.file-manager.nautilus = {
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

    system.services.defaultApps = {
      enable = true;
      defaultFileManager = "org.gnome.Nautilus.desktop";
    };
  };
}
