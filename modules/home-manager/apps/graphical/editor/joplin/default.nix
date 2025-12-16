{ config, lib, pkgs, nixGLWrapper, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkEnableOption types mkIf;
  cfg = config.apps.graphical.editor.joplin;
in
{
  options = {
    apps.graphical.editor.joplin = {
      enable = mkEnableOption "Enable's Joplin.";
    };
  };

  config = mkIf cfg.enable {
    # Jopin CLI fails to build on x86_64-darwin
    home = {
      #   packages = lib.optionals (platform != "x86_64-darwin") [ pkgs.joplin ];
      packages = with pkgs; [ work-sans ] ++
        mkIf (!isNixos) [ nerd-fonts.fira-code ];
    };

    programs.joplin-desktop = {
      # enable = isLinux;
      enable = true;
      package = nixGLWrapper pkgs.joplin-desktop;
      extraConfig = {
        "markdown.plugin.sub" = true;
        "markdown.plugin.sup" = true;
        "revisionService.ttlDays" = 180;
        "style.editor.fontFamily" = "Work Sans";
        "style.editor.fontSize" = 16;
        "style.editor.monospaceFontFamily" = "FiraCode Nerd Font Mono";
        "theme" = 7;
      };
    };
  };
}
