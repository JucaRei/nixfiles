{ config, desktop, pkgs, username, lib, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  walls = pkgs.fetchgit {
    url = "https://github.com/D3Ext/aesthetic-wallpapers";
    rev = "060c580dcc11afea2f77f9073bd8710920e176d8";
    sha256 = "5MnW630EwjKOeOCIAJdSFW0fcSSY4xmfuW/w7WyIovI=";
  };
in
{
  imports =
    [
      # ../services/emote.nix
      # (./. + "./${desktop}")
      # ../apps/documents/libreoffice.nix
      # ../services/flatpak.nix
      ../console/properties.nix
      # ../apps/browser/brave
      ../fonts
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop}
    ++ lib.optional
      (builtins.pathExists (./. + "/../../users/${username}/desktop.nix"))
      ../../users/${username}/desktop.nix;

  services = {
    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    mpris-proxy.enable = isLinux;
  };

  home = {
    # Authrorize X11 access in Distrobox
    file = lib.mkIf isLinux {
      ".distroboxrc" = {
        text = ''
          ${pkgs.xorg.xhost}/bin/xhost +si:localuser:$USER
        '';
      };
      file = {
        ".face" = {
          # source = ./face.jpg;
          source = "${pkgs.juca-avatar}/share/faces/juca.jpg";
        };
      };
      # "Pictures/wallpapers".source = lib.mkForce "${walls}/images";
    };
    packages = with pkgs; [
      black # Code format Python
      nodePackages.prettier # Code format
      shellcheck # Code lint Shell
      shfmt # Code format Shell
      # font-manager
      dconf2nix
      hexchat
      distrobox
    ] ++ lib.optionals (isDarwin) [
      # macOS apps
      iterm2
      pika
      utm
    ];
  };

  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
      left-handed = false;
      natural-scroll = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
  };
}
