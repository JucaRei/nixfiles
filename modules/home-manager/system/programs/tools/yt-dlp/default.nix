{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.programs.tools.yt-dlp;
in
{
  options = {
    system.programs.tools.yt-dlp.enable = mkEnableOption (
      mdDoc "Enable yt-dlp with custom aliases and aria2 integration."
    );
  };

  config = mkIf cfg.enable {
    programs = {
      yt-dlp = {
        enable = true;
        package = pkgs.unstable.yt-dlp;
        settings = {
          # Output & metadata
          output = "%(title)s.%(ext)s";
          add-metadata = true;
          embed-metadata = true;
          embed-info-json = true;
          embed-chapters = true;

          # Thumbnails
          write-thumbnail = true;
          convert-thumbnails = "png";
          embed-thumbnail = true;

          # Audio
          extract-audio = true;
          audio-format = "flac";
          audio-quality = 0;
          # audio-multistreams = true; # enable if you want multiple tracks

          # Video
          remux-video = "mkv";
          prefer-free-formats = true;

          # Subtitles
          write-subs = true;
          embed-subs = true;
          sub-format = "best";
          sub-lang = "en,br";

          # Download behavior
          concurrent-fragments = 5;
          download-path = {
            audio = "~/Music/downloads";
            video = "~/Videos/downloads";
            thumbnail = "~/Pictures/thumbnails";
          };
          download-archive = "~/.local/share/yt-dlp/archive.log";
          no-overwrites = true;
          no-call-home = true;

          # Downloader integration
          downloader = "${pkgs.aria2}/bin/aria2c";
          downloader-args = ''
            aria2c:
              --async-dns=false
              --continue=true
              --max-tries=5
              --retry-wait=5
              --max-download-limit=70M
              --min-split-size=1M
              --max-connection-per-server=8
              --split=16
              --file-allocation=none
              --log-level=warn
          '';

          aliases = {

            "ytdl-playlist-music" = [
              "sh"
              "-c"
              "folder=$(basename \"$PWD\"); \
              find . -type f \\( -iname '*.mp3' -o -iname '*.flac' -o -iname '*.m4a' \\) > \"$folder.m3u\""
            ];

            "ytdl-playlist-videos" = [
              "sh"
              "-c"
              "folder=$(basename \"$PWD\"); \
              find . -type f \\( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.avi' \\) > \"$folder.m3u\""
            ];

            "ytdl-flac" = [
              "--extract-audio"
              "--audio-format"
              "flac"
              "--audio-quality"
              "0" # best quality
              "--add-metadata" # add metadata tags
              "--embed-metadata" # embed into file
              "--embed-thumbnail" # cover art
              "--embed-info-json" # extra metadata (album, artist, etc.)
              "--output"
              "%(title)s.%(ext)s" # filename = music title
            ];

            "ytdl-flac-album" = [
              "--extract-audio"
              "--audio-format"
              "flac"
              "--audio-quality"
              "0"
              "--add-metadata"
              "--embed-metadata"
              "--embed-thumbnail"
              "--embed-info-json"
              "--output"
              "%(album)s/%(track_number)s - %(title)s.%(ext)s"
            ];

            "ytdl-flac-album-check" = [
              "sh"
              "-c"
              ''
                yt-dlp \
                  --extract-audio \
                  --audio-format flac \
                  --audio-quality 0 \
                  --add-metadata \
                  --embed-metadata \
                  --embed-thumbnail \
                  --embed-info-json \
                  --output "%(album)s/%(track_number)s - %(title)s.%(ext)s" "$1"

                echo "Checking metadata..."
                all_ok=true
                album_name=""

                for f in ./*.flac; do
                  album=$(ffprobe -v error -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$f")
                  track=$(ffprobe -v error -show_entries format_tags=track -of default=noprint_wrappers=1:nokey=1 "$f")
                  artist=$(ffprobe -v error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$f")

                  if [ -z "$album" ] || [ -z "$track" ] || [ -z "$artist" ]; then
                    echo "⚠️ Missing metadata in: $f"
                    all_ok=false
                  else
                    album_name="$album"
                    echo "✅ $f has album=$album, track=$track, artist=$artist"
                  fi
                done

                if [ "$all_ok" = true ] && [ -n "$album_name" ]; then
                  echo "All tracks have metadata — generating playlist..."
                  ls ./*.flac | sort > "$\{album_name}.m3u"
                  echo "Playlist created: $\{album_name}.m3u"
                else
                  echo "Playlist not created — missing metadata in some files."
                fi
              ''
            ];

            "ytv-best-playlist" = [
              "-f"
              "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=1080]+bestaudio"
              "--merge-output-format"
              "mp4"
              "--no-keep-video"
              "--embed-chapters"
              "--output"
              "%(playlist_uploader)s/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s"
            ];
          };
        };
      };
    };
  };
}
