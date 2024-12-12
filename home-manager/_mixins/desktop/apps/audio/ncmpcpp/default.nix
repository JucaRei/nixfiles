{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.desktop.apps.audio.ncmpcpp;
in
{
  options.desktop.apps.audio.ncmpcpp = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = "Enables ncmpcpp";
    };
  };
  config = mkIf cfg.enable {
    home = { packages = with pkgs; [ cava mpc-cli go-musicfox ]; };
    programs = {
      ncmpcpp = {
        enable = true;
        mpdMusicDir = null;
      };
    };
    home.file = {
      ".config/ncmpcpp/config".text = ''
        mpd_music_dir = ~/${config.home.homeDirectory}/Media/Music
      '';
    };
  };
}
