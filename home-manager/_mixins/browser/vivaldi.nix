{ pkgs, ... }: {
  home.packages = with pkgs.unstable; [
    vivaldi
    vivaldi-ffmpeg-codecs
  ];
}
