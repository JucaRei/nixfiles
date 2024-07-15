{ config, desktop, pkgs, username, lib, hostname, ... }:
with lib;
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
    ++ optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop}
    ++ optional
      (builtins.pathExists (./. + "/../../users/${username}/desktop.nix"))
      ../../users/${username}/desktop.nix;

  services = {
    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    mpris-proxy.enable = isLinux;
  };

  home = {
    # Authrorize X11 access in Distrobox
    file = mkIf isLinux {
      ".distroboxrc" = {
        text = ''
          ${pkgs.xorg.xhost}/bin/xhost +si:localuser:$USER
        '';
      };
      ".face" = {
        # source = ./face.jpg;
        source = "${pkgs.juca-avatar}/share/faces/juca.jpg";
      };
      "Pictures/wallpapers".source = mkForce "${walls}/images";
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
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.local/share/applications"
    ];
    pointerCursor = mkDefault {
      package = mkDefault pkgs.bibata-cursors;
      name = mkDefault "Bibata-Modern-Classic";
      size = mkDefault 22;
      gtk.enable = true;
      x11.enable = if ("${pkgs.elogind}/bin/loginctl show-session 2 -p Type" == "Type=x11") then true else false;
    };
  };

  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };
  };

  gtk = mkDefault {
    enable = true;
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = ''
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';
    }; #Fluent-Dark
    gtk3 = {
      extraConfig = {
        gtk-xft-rgba = "rgb";
        gtk-button-images = 1;
        gtk-menu-images = 1;
        gtk-enable-event-sounds = 1;
        gtk-enable-input-feedback-sounds = 1;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintfull"; #"hintslight";
        gtk-cursor-blink = true;
        gtk-recent-files-limit = 20;
        gtk-application-prefer-dark-theme = 1;
      };
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
          "file:///mnt/sharecenter/volume_1"
          "file:///mnt/sharecenter/volume_2"
        ];
    };
    gtk4 = {
      # gtk-icon-theme-name = "ePapirus-Dark";
      # gtk-theme-name = "Yaru-purple-dark";
      # gtk-cursor-theme-name = "volantes_cursors";
      # gtk-cursor-theme-size = "24";
      # gtk-font-name = "Fira Sans";
      #   gtk-theme-name = "Fluent-Dark";
      #   gtk-icon-theme-name = "Papirus-Dark";
      #   gtk-cursor-theme-name = "volantes_cursors";
      extraConfig.gtk-application-prefer-dark-theme = 1;
    };
    iconTheme = {
      # name = "ePapirus-Dark";
      # package = pkgs.papirus-icon-theme;
      package = mkDefault pkgs.catppuccin-papirus-folders;
      name = mkDefault "Papirus";
    };
    theme = {
      # Catppuccin
      name = "Catppuccin-Frappe-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        tweaks = [ "rimless" ];
        size = "compact";
        variant = "frappe";
      };
      # name = "Tokyonight-Dark-BL";
      # package = pkgs.tokyo-night-gtk;
    };
    cursorTheme = {
      # name = "volantes_cursors";
      # package = pkgs.volantes-cursors;
      # package = mkDefault pkgs.bibata-cursors;
      # name = mkDefault "Bibata-Modern-Classic";
      # size = mkDefault 22;
    };
    font = {
      # name = "Fira Code";
      # package = pkgs.fira-code;
      name = "Lexend";
      size = 11;
      package = pkgs.lexend;
    };
  };
}
