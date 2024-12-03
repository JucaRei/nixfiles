{ lib, pkgs, platform, username, config, ... }:
let
  installFor = [ "juca" ];
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkOption types mkIf;
  cfg = config.desktop.apps.joplin;
in
{
  options.desktop.apps.blackbox = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # Jopin CLI fails to build on x86_64-darwin
    home = mkIf (lib.elem username installFor) {
      packages = lib.optionals (platform != "x86_64-darwin") [ pkgs.joplin ];
    };

    programs.joplin-desktop = {
      enable = isLinux;
      extraConfig = {
        "markdown.plugin.sub" = true;
        "markdown.plugin.sup" = true;
        "revisionService.ttlDays" = 180;
        "style.editor.fontFamily" = "Work Sans";
        "style.editor.fontSize" = 16;
        "style.editor.monospaceFontFamily" = "FiraCode Nerd Font Mono";
        "theme" = 7;
      };
      sync = {
        interval = "1h";
        target = "dropbox";
      };
    };
  };
}
