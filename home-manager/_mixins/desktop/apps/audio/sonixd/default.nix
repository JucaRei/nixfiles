{ pkgs, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.audio.sonixd;
in
{
  options = {
    desktop.apps.audio.sonixd = {
      enable = mkEnableOption "Enables Front end for subsonic server";
    };
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
        exec = "${easytag}/bin/easytag ~/${config.home.homeDirectory}/Media/Music";
        categories = [ "Audio" ];
      })
    ];
  };
}
