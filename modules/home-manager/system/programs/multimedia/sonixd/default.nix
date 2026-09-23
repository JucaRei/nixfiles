{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.multimedia.sonixd;
in
{
  options.system.programs.multimedia.sonixd = {
    enable = mkEnableOption "Enables Front end for subsonic server";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sonixd # frontend for subsonic compatible servers
      # clementine
      sox # sample rate converter and spectrograms generator
      easytag # view and edit tags for various audio files
      (makeDesktopItem {
        name = "easytag";
        desktopName = "EasyTAG";
        genericName = "Open EasyTAG in Music dir.";
        icon = "easytag";
        exec = "${easytag}/bin/easytag ~/${config.xdg.userDirs.music}";
        categories = [ "Audio" ];
      })
    ];
  };
}
