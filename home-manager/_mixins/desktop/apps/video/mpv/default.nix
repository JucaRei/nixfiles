{ pkgs, lib, modulesPath, inputs, ... }:
let
  kvFormat = pkgs.formats.keyValue { };
  font = "FiraCode Nerd Font";

  ### Use's from unstable
  # mpv-unstable = pkgs.unstable.wrapMpv
  mpv-unstable = pkgs.unstable.mpv-unwrapped.wrapper
    {
      mpv = pkgs.unstable.mpv-unwrapped.override
        {
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
      scripts = with pkgs.unstable.mpvScripts;
        [
          # thumbnail
          thumbfast # High-performance on-the-fly thumbnailer.
          autoload # Automatically load playlist entries before and after the currently playing file, by scanning the directory.
          mpris
          uosc # Adds a minimalist but highly customisable GUI.
          acompressor
          webtorrent-mpv-hook # Adds a hook that allows mpv to stream torrents. It provides an osd overlay to show info/progress.
          inhibit-gnome
          autodeint # Automatically insert the appropriate deinterlacing filter based on a short section of the current video, triggered by key bind.
          sponsorblock
        ];
    };
in
{
  disabledModules = [
    "${modulesPath}/programs/mpv.nix" # disable module from stable branch
  ];

  imports = [
    (inputs.home-manager-unstable + "/modules/programs/mpv.nix") # imports module from unstable branch
  ];
}
