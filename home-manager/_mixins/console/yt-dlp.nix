{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.yt-dlp-custom;

  # mypython = with pkgs; python310;
  mypython = (pkgs.python310.withPackages (pythonPackages: with pythonPackages; [ ]));
in
{
  options.services.yt-dlp-custom = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    programs = {
      yt-dlp = {
        enable = true;
        package = pkgs.unstable.yt-dlp;
        settings = {
          audio-format = "best";
          audio-quality = 0;
          embed-chapters = true;
          embed-metadata = true;
          embed-thumbnail = true;
          remux-video = "aac>m4a/mov>mp4/mkv";
          sponsorblock-mark = "sponsor";
          sub-langs = "all";
          # Metadata
          add-metadata = true;
          embed-subs = true;
          xattrs = true;
          # Subtitles
          # write-auto-sub = true;
          write-sub = true;
          sub-format = "best";
          sub-lang = "en,br";
          # Downloader
          downloader = "${pkgs.aria2}/bin/aria2c";
          downloader-args = "aria2c:'--async-dns=false --max-download-limit=6M --min-split-size=1M --max-connection-per-server=4 --split=4'";
          # Other
          no-overwrites = true;
          no-call-home = true;
        };
        extraConfig = ''
          --ignore-errors
          -o ~/Videos/Youtube/%(title)s.%(ext)s
          # Prefer 1080p or lower resolutions
          -f bestvideo[ext=mp4][width<2000][height<=1200]+bestaudio[ext=m4a]/bestvideo[ext=webm][width<2000][height<=1200]+bestaudio[ext=webm]/bestvideo[width<2000][height<=1200]+bestaudio/best[width<2000][height<=1200]/best
        '';
      };
    };
    home = mkIf cfg.enable {
      shellAliases = {
        makeplay = ''
          find -type f -iname "*.mp3" -or -iname "*.ogg" -or -iname "*.flac" -or -iname "*.m4a" > playlist.m3u
        '';
        yta-aac = "yt-dlp --extract-audio --audio-format aac ";
        #  yta-best = "yt-dlp --extract-audio --audio-format best --output '%(title)s.%(ext)s' --no-keep-video ";
        #  yta-flac = "yt-dlp --extract-audio --audio-format flac --output '%(title)s.%(ext)s' --no-keep-video ";
        #  yta-m4a = "yt-dlp --extract-audio --audio-format m4a --output '%(title)s.%(ext)s' --no-keep-video ";
        yta-mp3 = "yt-dlp --extract-audio --audio-format mp3 --output '%(title)s.%(ext)s' --no-keep-video ";
        #  yta-opus = "yt-dlp --extract-audio --audio-format opus --output '%(title)s.%(ext)s' --no-keep-video ";
        #  yta-vorbis = "yt-dlp --extract-audio --audio-format vorbis --output '%(title)s.%(ext)s' --no-keep-video ";
        #  yta-wav = "yt-dlp --extract-audio --audio-format wav --output '%(title)s.%(ext)s' --no-keep-video ";
        ytv-best = "yt-dlp -f bestvideo+bestaudio --output '%(title)s.%(ext)s' --no-keep-video ";
        ytv-best-mp4 = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(title)s.%(ext)s' ";
        ytv-best-playlist = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(playlist_uploader)s/%(playlist_title)s/%(title)s. [%(id)s].%(ext)s' ";
        #  ytv-best-playlist2 = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(playlist_uploader)s/%(playlist_index)s/%(title)s. [%(id)s].%(ext)s' ";
        #  yt-plMed = "yt-dlp -f 'bestvideo[height<=720][ext=mp4]+bestaudio/best[height<=720][ext=m4a]' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(title)s.%(ext)s' ";
        yt-plHigh = "yt-dlp -f 'bestvideo[height<=1080][ext=mp4]+bestaudio/best[height<=1080][ext=m4a]' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(title)s.%(ext)s' ";
        #  # %(playlist_index)s
        #  # --parse-metadata "title:%(title)s | %(t1)s | %(t2)s | %(season)s | %(episode)s | %(t3)s" -o "MMPR_%(season)s%(episode)s_%(title)s.%(ext)s" --restrict-filenames

        # Audio
        ytmusic = "yt-dlp --no-overwrite --extract-audio --format bestaudio --audio-format aac --output '%(track_number,playlist_autonumber)d-%(track,title)s.%(ext)s' --download-archive --embed-thumbnail --add-metadata";
        ytmusic2 = "yt-dlp --no-overwrite --extract-audio --format bestaudio --audio-format aac --output 'chapter:%(section_number)s %(section_title)s.%(ext)s' --download-archive archive --embed-thumbnail --add-metadata";
        ytmusic3 = "yt-dlp --no-overwrite --extract-audio --embed-thumbnail --format bestaudio --audio-format aac --split-chapters --parse-metadata 'title:%%(artist)s - %%(album)s' --parse-metadata 'section_number:%%(track)d' --parse-metadata 'section_title:%%(title)s'";
        ytmusic4 = "yt-dlp --no-overwrite --extract-audio --embed-thumbnail --format bestaudio --audio-format aac --split-chapters --parse-metadata 'section_number:%%(track)d' --parse-metadata 'section_title:%%(title)s'";
        ytmusic5 = "yt-dlp --no-overwrite --extract-audio --embed-thumbnail --format bestaudio --audio-format aac --split-chapters --parse-metadata 'section_number:%%(track)d'";
        ytmusic6 = "yt-dlp --no-overwrite --extract-audio --embed-thumbnail --format bestaudio --audio-format aac --add-metadata --split-chapters --parse-metadata 'title:%%(artist)s - %%(album)s' -o 'chapter_number:%%(section_number)s chapter:%%(section_title)s.%%(ext)s'";
      };

      packages = with pkgs; [
        (writeScriptBin "youtube_channel_archiver" ("#!${mypython}/bin/python3\n" + (builtins.readFile ../config/yt-dlp-scripts/youtube_channel_archiver.py)))

        (writeScriptBin "single_song_downloader" (builtins.readFile ../config/yt-dlp-scripts/single_song_downloader.sh))
      ];
    };
  };
}
