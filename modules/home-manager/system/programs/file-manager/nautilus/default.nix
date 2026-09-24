{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.programs.nautilus;
in
{
  options = {
    programs.nautilus = {
      enable = mkEnableOption "Enable and set nautilus as default file-manager.";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs // pkgs.gnome; [
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
