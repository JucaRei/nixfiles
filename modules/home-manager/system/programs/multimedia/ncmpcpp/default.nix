{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.multimedia.ncmpcpp;
in
{
  options.system.programs.multimedia.ncmpcpp = {
    enable = lib.my.mkBool false "Enables ncmpcpp";
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        cava
        mpc-cli
        go-musicfox
      ];
    };
    programs = {
      ncmpcpp = {
        enable = true;
        mpdMusicDir = null;
      };
    };
    home.file = {
      ".config/ncmpcpp/config".text = ''
        mpd_music_dir = ~/${config.xdg.userDirs.music}
      '';
    };
  };
}
