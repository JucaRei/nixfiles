{ pkgs, lib, config, isWorkstation, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;
  cfg = config.system.services.nix-ld;
in
{
  options = {
    system.services.nix-ld = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Whether enable NixOS to run unpatched dynamic binaries.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable nix ld
    programs.nix-ld = {
      # create a link-loader for non-nix binaries
      enable = true;
      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged
        # programs here, NOT in environment.systemPackages
        # from https://github.com/Mic92/dotfiles/blob/main/nixos/modules/nix-ld.nix
        # stdenv.cc.cc
        # fuse3
        # alsa-lib
        # at-spi2-atk
        # at-spi2-core
        # atk
        # cairo
        # # cups
        # curl
        # dbus
        # expat
        # fontconfig
        # freetype
        # gdk-pixbuf
        # glib
        # gtk3
        # libGL
        # libappindicator-gtk3
        # libdrm
        # libnotify
        # libpulseaudio
        # libuuid
        # libusb1
        # xorg.libxcb
        # libxkbcommon
        # mesa
        # nspr
        # nss
        # pango
        # pipewire
        # systemd
        # icu
        # openssl
        # xorg.libX11
        # xorg.libXScrnSaver
        # xorg.libXcomposite
        # xorg.libXcursor
        # xorg.libXdamage
        # xorg.libXext
        # xorg.libXfixes
        # xorg.libXi
        # xorg.libXrandr
        # xorg.libXrender
        # xorg.libXtst
        # xorg.libxkbfile
        # xorg.libxshmfence
        # zlib
      ];
    };
  };
}
