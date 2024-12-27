{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOptionDefault;
in
{
  config = {
    home.packages = with pkgs ; [
      cloneit
      typora
      unstable.obsidian
      deluge-gtk
      nil
      nixpkgs-fmt
    ];

    console = {
      lsd.enable = true;
    };

    desktop.apps = {
      editors.vscode = {
        enable = true;
      };
      video = {
        mpv = { enable = true; };
      };
    };

    services = {
      flatpak = {
        enable = true;
        remotes = mkOptionDefault [{
          # name = "flathub-beta";
          # location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }];
        packages = [
          # { appId = "com.rtosta.zapzap"; origin = "flathub"; }
          "com.rtosta.zapzap"
        ];

        update.auto = {
          enable = true;
          onCalendar = "weekly"; # Default value
        };
      };
    };
  };
}
