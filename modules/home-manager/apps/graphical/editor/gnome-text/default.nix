{ config, lib, pkgs, osConfig ? null, nixGLWrapper, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  isNixOS = osConfig != null;
  cfg = config.apps.graphical.editor.gnome-text;
in
with lib.hm.gvariant;
{
  options = {
    apps.graphical.editor.gnome-text = {
      enable = mkEnableOption "Enables gnome-text editor.";
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = [ (nixGLWrapper pkgs.gnome-text-editor) ] ++
      mkIf (!isNixos) [ pkgs.nerd-fonts.fira-code ];

    dconf.settings = {
      ### Text Editor
      "org/gnome/TextEditor" = {
        custom-font = "FiraCode Nerd Font Mono Medium 14";
        highlight-current-line = true;
        indent-style = "space";
        show-line-numbers = true;
        show-map = true;
        show-right-margin = true;
        style-scheme = "builder-dark";
        tab-width = mkUint32 4;
        use-system-font = false;
      };
    };
  };
}
