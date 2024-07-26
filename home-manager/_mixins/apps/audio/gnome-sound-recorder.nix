{ config, lib, pkgs, username, ... }:
with lib;
with lib.hm.gvariant;
let
  cfg = config.programs.gnome-sound-recorder;
in
{
  options.programs.gnome-sound-recorder = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gnome.gnome-sound-recorder ];

    dconf.settings = {
      "org/gnome/SoundRecorder" = {
        audio-channel = "mono";
        audio-profile = "flac";
      };
    };

    systemd.user.tmpfiles.rules = [
      "d ${config.home.homeDirectory}/Music/Audio 0755 ${username} users - -"
      "L+ ${config.home.homeDirectory}/.local/share/org.gnome.SoundRecorder/ - - - - ${config.home.homeDirectory}/Music/Audio/"
    ];
  };
}
