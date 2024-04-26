{ pkgs, lib, hostname, desktop, ... }:
with lib;
let
  isInstall = if (builtins.substring 0 4 hostname != "iso-") then true else false;
in

{
  config = {
    # binfmt.registrations.appImage = lib.mkIf (isWorkstation) {
    #   # make appImage work seamlessly
    #   wrapInterpreterInShell = false;
    #   interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    #   recognitionType = "magic";
    #   offset = 0;
    #   # mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    #   mask = "\\xff\\xff\\xff\\xff\\x00\\x00\\x00\\x00\\xff\\xff\\xff";
    #   magicOrExtension = "\\x7fELF....AI\\x02";
    #   # magicOrExtension = ''\x7fELF....AI\x02'';
    # };

    environment.systemPackages = [ pkgs.appimage-run ];

    # run appimages with appimage-run
    boot.binfmt.registrations = genAttrs [ "appimage" "AppImage" ] (ext: {
      recognitionType = "extension";
      magicOrExtension = ext;
      interpreter = "/run/current-system/sw/bin/appimage-run";
    });

    nix-ld = mkIf (isInstall) {
      enable = true;
      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged
        # programs here, NOT in environment.systemPackages
        stdenv.cc.cc
        fuse3
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        curl
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libGL
        libappindicator-gtk3
        libdrm
        libnotify
        libpulseaudio
        libuuid
        libusb1
        xorg.libxcb
        libxkbcommon
        mesa
        nspr
        nss
        pango
        pipewire
        systemd
        icu
        openssl
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        xorg.libxkbfile
        xorg.libxshmfence
        zlib
      ];
    };
  };
}
