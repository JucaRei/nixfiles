{ config, lib, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
in
with lib.hm.gvariant;
{
  imports = [
    # ../../_mixins/apps/audio/audio-recorder.nix
    # ../../_mixins/apps/audio/gnome-sound-recorder.nix
    # ../../_mixins/apps/browser/vivaldi.nix
    # ../../_mixins/apps/browser/firefox.nix
    ../../_mixins/apps/music/rhythmbox.nix
    # ../../_mixins/apps/video/mpv.nix
    ../../_mixins/apps/tools/dconf-editor.nix
    # ../../_mixins/apps/tools/gitkraken.nix
    # ../../_mixins/apps/tools/meld.nix
    # ../../_mixins/apps/terminal/sakura.nix
    # ../../_mixins/apps/terminal/tilix.nix
    # ../../_mixins/services/emote.nix
    # ../../_mixins/services/localsend.nix
    # ../../_mixins/apps/video/celluloid.nix
  ];

  dconf.settings = {
    "org/gnome/rhythmbox/rhythmdb" = {
      locations = [ "file://${config.home.homeDirectory}/Music" ];
      monitor-library = true;
    };
  };

  # Authrorize X11 access in Distrobox
  home.file.".distroboxrc" = lib.mkIf isLinux {
    text = ''
      xhost +si:localuser:$USER
    '';
  };
}
