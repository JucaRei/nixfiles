{ config, desktop, pkgs, username, lib, hostname, ... }:
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
      # ../apps/documents/libreoffice.nix
      # ../services/flatpak.nix
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
      ".face" = {
        # source = ./face.jpg;
        source = "${pkgs.juca-avatar}/share/faces/juca.jpg";
      };
      "Pictures/wallpapers".source = lib.mkForce "${walls}/images";
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
    sessionVariables = {
      # Enable icons in tooling since we have nerdfonts.
      # LOG_ICONS = "true";
    };
  };
  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };
  };

  gtk = {
    gtk3 = {
      extraCss = "
        VteTerminal, vte-terminal {
          padding: 13px;
        }";
      bookmarks =
        if hostname == "nitro" then [
          "file:///home/${username}/Documents"
          "file:///home/${username}/Documents/Virtualmachines"
          "file:///home/${username}/Documents/docker"
          "file:///home/${username}/Downloads"
          "file:///home/${username}/Pictures"
          "file:///home/${username}/Music"
          "file:///home/${username}/Videos"
          "file:///home/${username}/Documents/lab"
          "smb://192.168.1.207/volume_1/"
          "smb://192.168.1.207/volume_2/Transmission/complete"
        ] else [
          "file:///home/${username}/Documents"
          "file:///home/${username}/Documents/Virtualmachines"
          "file:///home/${username}/Documents/docker"
          "file:///home/${username}/Downloads"
          "file:///home/${username}/Pictures"
          "file:///home/${username}/Music"
          "file:///home/${username}/Videos"
          "file:///home/${username}/Documents/lab"
          "/mnt/sharecenter/volume_1"
          "/mnt/sharecenter/volume_2"
        ];
    };
  };
}
