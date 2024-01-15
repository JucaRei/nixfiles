{ pkgs, lib, config, ... }:
with lib.hm.gvariant;
let
  nixGL = import ../../../../lib/nixGL.nix { inherit config pkgs; };

  mpvgl = pkgs.wrapMpv
    (pkgs.mpv-unwrapped.override {
      # webp support
      ffmpeg = pkgs.ffmpeg_5-full;
    })
    {
      scripts = with pkgs.mpvScripts; [
        thumbnail
        mpris
        acompressor
        # thumbfast
        sponsorblock
      ]
      # Custom scripts
      ++ (with pkgs;[
        # anime4k
        # dynamic-crop
        # modernx
        # nextfile
        ## subselect
        # subsearch
        # thumbfast
      ]);
    };
in
{
  programs = {
    mpv = {
      enable = true;
      package = (nixGL mpvgl);
    };
  };

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
            {
              blacklist = [
                "signs"
                "songs"
                "translation only"
                "forced"
              ];
            }
            {
              alang = "*";
              slang = "eng";
            }
          ];
        };
        ".config/mpv/script-opts/stats.conf" = {
          source = kvFormat.generate "mpv-script-opts-stats" {
            font = font;
            font_mono = font;
            #BBGGRR
            font_color = "C6BD0A";
            border_color = "1E0B00";
            plot_bg_border_color = "D900EA";
            plot_bg_color = "331809";
            plot_color = "D900EA";
          };
        };
      };
    };

  # xdg = {
  #   configfile =
  #     let
  #       kvFormat = pkgs.formats.keyValue { };
  #       font = "FiraCode Nerd Font";
  #     in
  #     {
  #       "mpv/script-opts/chapterskip.conf".text = "categories=sponsorblock>SponsorBlock";
  #       "mpv/script-opts/sub-select.json".text = builtins.toJSON [
  #         {
  #           blacklist = [ "signs" "songs" "translation only" "forced" ];
  #         }
  #         {
  #           alang = "*";
  #           slang = "eng";
  #         }
  #       ];
  #       # "mpv/mpv.conf".source = ../../config/mpv/mpv.conf;
  #       "mpv/script-opts/console.conf".source = kvFormat.generate "mpv-script-opts-console" {
  #         font = font;
  #       };
  #       # "mpv/script-opts/osc.conf".source = kvFormat.generate "mpv-script-opts-osc" {
  #       #   seekbarstyle = "diamond";
  #       # };
  #       "mpv/script-opts/stats.conf".source = kvFormat.generate "mpv-script-opts-stats" {
  #         font = font;
  #         font_mono = font;
  #         #BBGGRR
  #         font_color = "C6BD0A";
  #         border_color = "1E0B00";
  #         plot_bg_border_color = "D900EA";
  #         plot_bg_color = "331809";
  #         plot_color = "D900EA";
  #       };
  #     };
  # };
}
