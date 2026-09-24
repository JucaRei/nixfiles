{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.system.programs.tools.yt-dlp;
  shouldInstall = cfg.installPackage && !cfg.useSystemPackage && !cfg.useSystemPackages;
in
{
  options = {
    system.programs.tools.yt-dlp = {
      enable = mkEnableOption "Enable yt-dlp with custom aliases and aria2 integration.";

      installPackage = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Se deve instalar o executável do yt-dlp via Nix.
          Se false, apenas o arquivo de configuração (~/.config/yt-dlp/config) e aliases serão gerenciados, utilizando o binário nativo da distro hospedeira.
        '';
      };

      useSystemPackage = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Atalho conveniente: quando true, equivale a installPackage = false.
        '';
      };

      useSystemPackages = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Alias para useSystemPackage.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      yt-dlp = {
        enable = true;
        package = if shouldInstall then pkgs.unstable.yt-dlp else pkgs.emptyDirectory;
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
          download-archive = "~/.local/share/yt-dlp/archive.log";
          no-overwrites = true;
          no-call-home = true;

          # Downloader integration
          downloader = "${pkgs.aria2}/bin/aria2c";
          downloader-args = "aria2c:--async-dns=false --continue=true --max-tries=5 --retry-wait=5 --max-download-limit=70M --min-split-size=1M --max-connection-per-server=8 --split=16 --file-allocation=none --log-level=warn";
        };

        # ── Opções que o HM settings não suporta (attrsets aninhados, aliases) ──
        # download-path e aliases precisam de linhas raw no config do yt-dlp.
        extraConfig = ''
          # Download paths por tipo
          -P "audio:~/Music/downloads"
          -P "video:~/Videos/downloads"
          -P "thumbnail:~/Pictures/thumbnails"

          # ── Aliases ──────────────────────────────────────────────────────────
          --alias ytdl-flac --extract-audio --audio-format flac --audio-quality 0 --add-metadata --embed-metadata --embed-thumbnail --embed-info-json --output "%(title)s.%(ext)s"

          --alias ytdl-flac-album --extract-audio --audio-format flac --audio-quality 0 --add-metadata --embed-metadata --embed-thumbnail --embed-info-json --output "%(album)s/%(track_number)s - %(title)s.%(ext)s"

          --alias ytv-best-playlist -f "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=1080]+bestaudio" --merge-output-format mp4 --no-keep-video --embed-chapters --output "%(playlist_uploader)s/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s"
        '';
      };
    };
  };
}

