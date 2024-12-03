{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.desktop.apps.ncmpcpp;
in
{
  options.desktop.apps.ncmpcpp = {
    enable = mkOption {
      default = false;
      type = types.bool;
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
        mpd_music_dir = ~/Music
      '';
    };
  };
}
