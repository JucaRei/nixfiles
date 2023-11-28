{ config, desktop, pkgs, username, lib, ... }: {
  imports = [
    # ../services/emote.nix

    # (./. + "./${desktop}")
    # ../apps/documents/libreoffice.nix
  ]
  ++ lib.optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop}
  ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix
  ++ lib.optional (builtins.pathExists (./. + "/../../users/${username}/desktop.nix")) ../../users/${username}/desktop.nix;

  services = {
    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    mpris-proxy.enable = true;

    udiskie = {
      enable = true;
      tray = "auto";
      automount = true;
    };
  };

  home = {
    packages = with pkgs; [
      font-manager
      dconf2nix
      hexchat
      usbimager
    ];
    # sessionVariables = {
    #   XDG_DATA_DIRS = lib.mkDefault "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"; # lets flatpak work
    # };
  };
  xresources.properties = {
    "XTerm*background" = "#121214";
    "XTerm*foreground" = "#c8c8c8";
    "XTerm*cursorBlink" = true;
    "XTerm*cursorColor" = "#FFC560";
    "XTerm*boldColors" = false;

    #Black + DarkGrey
    "*color0" = "#141417";
    "*color8" = "#434345";
    #DarkRed + Red
    "*color1" = "#D62C2C";
    "*color9" = "#DE5656";
    #DarkGreen + Green
    "*color2" = "#42DD76";
    "*color10" = "#A1EEBB";
    #DarkYellow + Yellow
    "*color3" = "#FFB638";
    "*color11" = "#FFC560";
    #DarkBlue + Blue
    "*color4" = "#28A9FF";
    "*color12" = "#94D4FF";
    #DarkMagenta + Magenta
    "*color5" = "#E66DFF";
    "*color13" = "#F3B6FF";
    #DarkCyan + Cyan
    "*color6" = "#14E5D4";
    "*color14" = "#A1F5EE";
    #LightGrey + White
    "*color7" = "#c8c8c8";
    "*color15" = "#e9e9e9";
    "XTerm*faceName" = "FiraCode Nerd Font:size=13:style=Medium:antialias=true";
    "XTerm*boldFont" = "FiraCode Nerd Font:size=13:style=Bold:antialias=true";
    "XTerm*geometry" = "132x50";
    "XTerm.termName" = "xterm-256color";
    "XTerm*locale" = false;
    "XTerm*utf8" = true;
    "Xcursor.theme" = lib.mkDefault "Breeze Hacked";
  };
}
