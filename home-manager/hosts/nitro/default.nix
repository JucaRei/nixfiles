{ pkgs, lib, ... }:
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
      remmina
      nixpkgs-fmt
      unstable.spotube
    ];

    console = {
      aliases.enable = true;
      lsd.enable = true;
      yt-dlp-custom.enable = true;
      aria2.enable = true;
      fastfetch.enable = true;
      fzf.enable = false;
      skim.enable = true;
      fish.enable = true;
    };

    desktop.apps = {
      editors = {
        vscode = {
          enable = true;
        };
      };
      video = {
        mpv = { enable = false; };
      };
      browser = {
        chrome-based-browser = {
          enable = false;
          browser = "opera";
          disableWayland = true;
        };
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
