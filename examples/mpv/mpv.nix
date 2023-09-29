{ pkgs, config, ... }:
let
  ffmpeg_5 = pkgs.ffmpeg_5-full;
  scripts = with pkgs.mpvScripts; [ sponsorblock ];
  mpv = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { inherit ffmpeg_5; }) {
    inherit scripts;
  };

in
{
  home.packages = [ ffmpeg_5 ];
  programs.mpv = {
    enable = true;
    package = mpv;
    config = {
      slang = "eng,en";
      alang = "eng,en";
      hwdec = "vaapi";
      vo = "gpu";

      audio-display = "no";
      audio-normalize-downmix = "yes";
      replaygain = "track";

      script-opts-set =
        "sponsorblock-local_database=no,sponsorblock-skip_categories=[sponsor,intro,selfpromo]";
    };
    # Don't make this profile default since not all machines can handle it
    profiles.gpu-hq = {
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
    };

    # 1.5 times speed, ≈702 cents pitch up
    profiles.wat = {
      speed = "1.5";
      audio-pitch-correction = "no";
    };

    bindings = {
      WHEEL_UP = "ignore";
      WHEEL_DOWN = "ignore";
      WHEEL_LEFT = "ignore";
      WHEEL_RIGHT = "ignore";
      k = "add sub-scale -0.1";
      K = "add sub-scale +0.1";
      "[" = "add speed -0.1";
      "]" = "add speed 0.1";
      "{" = "add speed -1";
      "}" = "add speed 1";
    };
  };
}
