{ pkgs, lib, ... }:
let
  inherit (lib) mkOptionDefault mkForce;
in
{
  imports = [
    ../../_mixins/services/git
  ];
  home.packages = with pkgs ; [
    # cloneit
    typora
    # unstable.obsidian
    deluge-gtk
    remmina
    nixpkgs-fmt
    oldstable.spotube
    # heynote
  ];

  console = {
    aliases.enable = true;
    lsd.enable = mkForce false;
    eza.enable = true;
    yt-dlp-custom.enable = true;
    aria2.enable = true;
    fastfetch.enable = true;
    fzf.enable = false;
    skim.enable = false;
    fish.enable = true;
    dircolors.enable = true;
  };

  custom.services.git = {
    enable = true;
    user = "Reinaldo";
    email = "reinaldo800@gmail.com";
  };

  desktop.apps = {
    editors = {
      vscode = {
        enable = true;
      };
    };
    # video = {
    #   mpv = { enable = false; };
    # };
    # browser = {
    #   chrome-based-browser = {
    #     enable = false;
    #     browser = "opera";
    #     disableWayland = true;
    #   };
    # };
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
        "md.obsidian.Obsidian"
      ];

      update.auto = {
        enable = true;
        onCalendar = "weekly"; # Default value
      };
    };
  };
}
