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

      installPackage = lib.my.mkBool true ''
        Se deve instalar o executável do yt-dlp via Nix.
        Se false, apenas o arquivo de configuração (~/.config/yt-dlp/config) e aliases serão gerenciados, utilizando o binário nativo da distro hospedeira.
      '';

      useSystemPackage = lib.my.mkBool false "Atalho conveniente: quando true, equivale a installPackage = false.";

      useSystemPackages = lib.my.mkBool false "Alias para useSystemPackage.";
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
          # extract-audio fica apenas nos aliases dedicados (ex: ytdl-audio), evitando que vídeos comuns sejam convertidos para áudio por padrão
          # opus oferece a melhor relação qualidade/tamanho: aproveita o stream nativo Opus do YouTube sem reencode com fidelidade transparente e arquivos de ~3-5MB
          audio-format = "opus";
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
          download-archive = "${config.home.homeDirectory}/.local/share/yt-dlp/archive.log";
          no-overwrites = true;
          no-call-home = true;

          # Downloader integration
          downloader = "${pkgs.aria2}/bin/aria2c";
          # Aspas simples internas necessárias para o shlex do yt-dlp não quebrar os argumentos do aria2c na leitura do config
          downloader-args = "aria2c:'--async-dns=false --continue=true --max-tries=5 --retry-wait=5 --max-download-limit=70M --min-split-size=1M --max-connection-per-server=8 --split=16 --file-allocation=none --log-level=warn'";
        };

        # ── Opções que o HM settings não suporta (attrsets aninhados, aliases) ──
        # download-path e aliases precisam de linhas raw no config do yt-dlp.
        extraConfig = ''
          # Download paths padrão
          # O yt-dlp só aceita tipos: home, temp, thumbnail, subtitle, description, infojson, etc.
          # Não existem tipos 'video:' ou 'audio:'; mídias principais usam o caminho base (home:).
          -P "home:${config.home.homeDirectory}/Videos/downloads"
          -P "thumbnail:${config.home.homeDirectory}/Pictures/thumbnails"

          # ── Aliases ──────────────────────────────────────────────────────────
          # Vídeo avulso (baixa em melhor qualidade até 1080p, ignora playlist se o link tiver &list=)
          --alias ytdl-video "--no-playlist -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]/best' --merge-output-format mkv --embed-chapters --embed-subs --output '%(title)s.%(ext)s'"

          # Vídeo avulso em resolução máxima (sem teto de 1080p, 4K/2K)
          --alias ytdl-video-max "--no-playlist -f 'bestvideo+bestaudio/best' --merge-output-format mkv --embed-chapters --embed-subs --output '%(title)s.%(ext)s'"

          # Playlist de vídeos (organizada em pasta por canal/playlist com índice sequencial 01, 02...)
          --alias ytdl-playlist "--yes-playlist -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]/best' --merge-output-format mkv --embed-chapters --embed-subs -P '${config.home.homeDirectory}/Videos/downloads/Playlists/%(uploader,channel)s/%(playlist_title)s' --output '%(playlist_index)02d - %(title)s.%(ext)s'"

          # Canal completo (baixa todos os vídeos organizados por canal com data no nome)
          --alias ytdl-channel "--yes-playlist -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]/best' --merge-output-format mkv --embed-chapters --embed-subs -P '${config.home.homeDirectory}/Videos/downloads/Channels/%(uploader,channel)s' --output '%(upload_date>%Y-%m-%d)s - %(title)s.%(ext)s'"

          # ── Áudio: Melhor benefício de qualidade e tamanho (Opus nativo ~160k, remux sem perda/reencode) ──
          # Áudio avulso em Opus (ótima fidelidade, ~3-5MB por música)
          --alias ytdl-audio "--no-playlist --extract-audio --audio-format opus --audio-quality 0 --add-metadata --embed-metadata --embed-thumbnail --embed-info-json -P '${config.home.homeDirectory}/Music/downloads' --output '%(title)s.%(ext)s'"

          # Álbum ou Playlist de áudio em Opus (organizado em Artista/Álbum)
          --alias ytdl-audio-album "--yes-playlist --extract-audio --audio-format opus --audio-quality 0 --add-metadata --embed-metadata --embed-thumbnail --embed-info-json -P '${config.home.homeDirectory}/Music/downloads/%(album_artist,uploader)s/%(album,playlist_title)s' --output '%(track_number,playlist_index)02d - %(title)s.%(ext)s'"

          # Áudio em MP3 (caso precise de compatibilidade com tocadores legados/carros)
          --alias ytdl-mp3 "--no-playlist --extract-audio --audio-format mp3 --audio-quality 0 --add-metadata --embed-metadata --embed-thumbnail --embed-info-json -P '${config.home.homeDirectory}/Music/downloads' --output '%(title)s.%(ext)s'"

          # Áudio em FLAC (lossless, ideal para fontes lossless como Bandcamp)
          --alias ytdl-flac "--no-playlist --extract-audio --audio-format flac --audio-quality 0 --add-metadata --embed-metadata --embed-thumbnail --embed-info-json -P '${config.home.homeDirectory}/Music/downloads' --output '%(title)s.%(ext)s'"

          # Álbum ou Playlist de áudio em FLAC
          --alias ytdl-flac-album "--yes-playlist --extract-audio --audio-format flac --audio-quality 0 --add-metadata --embed-metadata --embed-thumbnail --embed-info-json -P '${config.home.homeDirectory}/Music/downloads/%(album_artist,uploader)s/%(album,playlist_title)s' --output '%(track_number,playlist_index)02d - %(title)s.%(ext)s'"

          # Legado mantido para compatibilidade
          --alias ytv-best-playlist "--yes-playlist -f 'bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=1080]+bestaudio' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(playlist_uploader)s/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s'"
        '';
      };
    };

    home.shellAliases = {
      ytdl = "yt-dlp";
      ytdl-video = "yt-dlp --ytdl-video";
      ytdl-video-max = "yt-dlp --ytdl-video-max";
      ytdl-playlist = "yt-dlp --ytdl-playlist";
      ytdl-channel = "yt-dlp --ytdl-channel";
      # Áudio (Opus = melhor relação qualidade vs tamanho)
      ytdl-audio = "yt-dlp --ytdl-audio";
      ytdl-audio-album = "yt-dlp --ytdl-audio-album";
      ytdl-mp3 = "yt-dlp --ytdl-mp3";
      # Lossless (FLAC)
      ytdl-flac = "yt-dlp --ytdl-flac";
      ytdl-flac-album = "yt-dlp --ytdl-flac-album";
    };
  };
}
