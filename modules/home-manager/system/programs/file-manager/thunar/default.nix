{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.file-manager.thunar;

  thunar-with-plugins = pkgs.thunar.override {
    thunarPlugins = [
      pkgs.thunar-volman
      pkgs.thunar-archive-plugin
      pkgs.thunar-media-tags-plugin
    ];
  };
in
{
  options = {
    system.programs.file-manager.thunar = {
      enable = mkEnableOption "Enable Thunar file manager with plugins and thumbnails support.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      thunar-with-plugins
      tumbler
      xarchiver
      file-roller
      webp-pixbuf-loader
      libgsf
      poppler
      freetype
    ];

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = "thunar.desktop";
    };
  };
}
