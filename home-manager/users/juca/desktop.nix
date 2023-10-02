{ config, lib, pkgs, username, ... }:
with lib.hm.gvariant;
{
  imports = [
    # ../../_mixins/audio/audio-recorder.nix
    # ../../_mixins/audio/gnome-sound-recorder.nix
    ../../_mixins/browser/vivaldi.nix
    # ../../_mixins/browser/firefox.nix
    ../../_mixins/music/rhythmbox.nix
    ../../_mixins/tools/dconf-editor.nix
    # ../../_mixins/tools/gitkraken.nix
    # ../../_mixins/tools/meld.nix
    # ../../_mixins/terminal/sakura.nix
    # ../../_mixins/terminal/tilix.nix
    # ../../_mixins/services/emote.nix
    ../../_mixins/services/localsend.nix
    # ../../_mixins/text-editor/vscode.nix
    # ../../_mixins/video/celluloid.nix
  ];

  dconf.settings = {
    "org/gnome/rhythmbox/rhythmdb" = {
      locations = [ "file://${config.home.homeDirectory}/Music" ];
      monitor-library = true;
    };
  };

  # Authrorize X11 access in Distrobox
  home.file.".distroboxrc".text = ''
    xhost +si:localuser:$USER
  '';
}
