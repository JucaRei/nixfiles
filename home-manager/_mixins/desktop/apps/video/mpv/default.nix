{ pkgs, lib, modulesPath, inputs, desktop, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.video.mpv;

  ### Use's from unstable
  # mpv-unstable = pkgs.unstable.wrapMpv
  mpv-unstable = pkgs.unstable.mpv-unwrapped.wrapper {
    # mpv = pkgs.unstable.mpv-unwrapped.override {
    mpv = pkgs.unstable.mpv-shim-default.shaders.override {
      vapoursynthSupport = true;
      cddaSupport = true; # Support for playing CDs with `mpv cdda:///dev/sr0`
      waylandSupport = true;
      jackaudioSupport = true; # Add jack support to mpv.
      # webp support
      ffmpeg = pkgs.unstable.ffmpeg_7-full;
    };
    youtubeSupport = true;
    extraMakeWrapperArgs = [
      "--prefix"
      "LD_LIBRARY_PATH"
      ":"
      "${pkgs.unstable.vapoursynth-mvtools}/lib/vapoursynth"
    ];
    scripts = with pkgs.unstable.mpvScripts; [
      # thumbnail
      thumbfast # High-performance on-the-fly thumbnailer.
      mpris
      uosc # Adds a minimalist but highly customisable GUI.
      #modernz # Sleek and modern OSC for mpv designed to enhance functionality by adding more features, all while preserving the core standards of mpv's OSC
      builtins.autoload # Automatically load playlist entries before and after the currently playing file, by scanning the directory.
      builtins.acompressor # Script to toggle and control ffmpeg's dynamic range compression filter
      quality-menu # Userscript for MPV that allows you to change youtube video quality (ytdl-format) on the fly
      # webtorrent-mpv-hook # Adds a hook that allows mpv to stream torrents. It provides an osd overlay to show info/progress.
      autodeint # Automatically insert the appropriate deinterlacing filter based on a short section of the current video, triggered by key bind.
      sponsorblock
      mpv-cheatsheet # MPV script for looking up keyboard shortcuts
    ] ++ mkIf (desktop == "gnome") [ inhibit-gnome ];
  };


in
{
  disabledModules = [
    "${modulesPath}/programs/mpv.nix" # disable module from stable branch
  ];

  imports = [
    (inputs.home-manager_unstable + "/modules/programs/mpv.nix") # imports module from unstable branch
  ];

  options = {
    desktop.apps.video.mpv = {
      enable = mkEnableOption "Enable's mpv with some configs.";
    };
  };

  config = mkIf cfg.enable {
    home =
      let
        kvFormat = pkgs.formats.keyValue { };
        font = "FiraCode Nerd Font";
      in
      {
        file = {
          ".config/mpv/script-opts/chapterskip.conf" = {
            text = "categories=sponsorblock>SponsorBlock";
          };

          ".config/mpv/script-opts/sub-select.json" = {
            text = builtins.toJSON [
              { blacklist = [ "signs" "songs" "translation only" "forced" ]; }
              {
                alang = "*";
                slang = "pt_BR,en,eng,de,deu,ger";
              }
            ];
          };

          ".config/mpv/script-opts/console.conf" = {
            text = "font=FiraCode Nerd Font Retina";
          };

          ".config/mpv/script-opts/stats.conf" = {
            source = kvFormat.generate "mpv-script-opts-stats" {
              font = font;
              font_mono = font;
              #BBGGRR
              font_color = "C6BD0A";
              border_color = "1E0B00";
              plot_bg_border_color = "D900EA";
              plot_bg_color = "9";
              plot_color = "D900EA";
            };
          };

          ".config/mpv/vapoursynth/motion-based-interpolation.vpy" = {
            source = ./configs/vapoursynth/motion-based-interpolation.vpy;
          };

          # ".config/mpv/input.conf" = builtins.readFile ./configs/input.conf;
          ".config/mpv/input.conf" = { source = ./configs/input.conf; };
          ".config/mpv/mpv.conf" = { source = ./configs/mpv.conf; };
          ".config/mpv/profiles.conf" = { source = ./configs/profiles.conf; };

          ".config/mpv/scripts/evfast.lua" = { source = ./configs/scripts/evfast.lua; };
          ".config/mpv/scripts/memo.lua" = { source = ./configs/scripts/memo.lua; };
          ".config/mpv/scripts/sview.lua" = { source = ./configs/scripts/sview.lua; };

          ".config/mpv/script-opts/evfast.conf" = { source = ./configs/scripts-opts/evfast.conf; };
          ".config/mpv/script-opts/memo.conf" = { source = ./configs/scripts-opts/memo.conf; };
          ".config/mpv/script-opts/thumbfast.conf" = { source = ./configs/scripts-opts/thumbfast.conf; };
          ".config/mpv/script-opts/uosc.conf" = { source = ./configs/scripts-opts/uosc.conf; };
        };
      };
  };
}
