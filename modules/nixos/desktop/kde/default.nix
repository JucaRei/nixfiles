{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkIf mkForce;
  isWayland = if (config.services.xserver.displayManager.sddm.wayland.enable == true) then "wayland" else "x11";

in
{
  config = {
    features.graphics = {
      backend = isWayland;
    };

    programs = {
      kdeconnect = {
        # For GSConnect
        enable = mkForce true;
      };
    };

    services = {
      xserver = {
        enable = true;
        displayManager = {
          # defaultSession = "plasma"; #plasmax11
          defaultSession = "plasmax11";
          sddm = {
            enable = true;
            autoNumlock = true;
            wayland = {
              enable = mkForce false;
            };
            # theme = "${pkgs.sddm-astronaut}";
            settings = {
              Theme = {
                CursorTheme = "layan-border_cursors";
              };
            };
          };
        };
        # desktopManager = {
        #   plasma5 = {
        #     useQtScaling = true;
        #     runUsingSystemd = true;
        #     phononBackend = "vlc";
        #     enable = true;
        #   };
        # };
      };
      desktopManager.plasma6 = {
        enable = true; # Desktop Environment
        enableQt5Integration = true;
      };
    };

    environment = {
      systemPackages =
        (with pkgs.libsForQt5; [
          # System-Wide Packages
          bismuth # Dynamic Tiling
          packagekit-qt # Package Updater
          kaccounts-integration
          kaccounts-providers
        ])
        ++ (with pkgs // pkgs.kdePackages; [
          # Flatpak
          # libportal
          # libportal-qt5
          libportal-qt6
          libportal-gtk4
          # libportal-gtk3

          # Multimedia Utilities
          # ffmpeg # ffprobe ffmpeg
          # ffmpegthumbnailer # ffmpegthumbnailer
          # libdvdcss # A library for decrypting DVDs
          # libdvdread # A library for reading DVDss
          # libopus
          # libvorbis
          # mediainfo # mediainfo
          # mpg123 # out123 conplay mpg123-id3dump mpg123 mpg123-strip
          # mplayer # gmplayer mplayer mencoder
          # mpv
          # ocamlPackages.gstreamer # mpv mpv_identify.sh umpv
          # simplescreenrecorder # ssr-glinject simplescreenrecorder
          # video-trimmer # video-trimmer

          qtstyleplugin-kvantum
          kio

          # Miscellaneous:
          # variety # A wallpaper manager for Linux systems

          # Picture manager
          # digikam # Photo Management Program
          # shotwell # Popular photo organizer for the GNOME desktop

          # KDE Plasma tools
          # kdiff3 # Compares and merges 2 or 3 files or directories
          ark # Graphical file compression/decompression utility
          filelight # Disk usage statistics
          kate # Advanced text editor
          kcalc # Scientific calculator
          kgpg # A KDE based interface for GnuPG, a powerful encryption utility
          # krename

          # keepassxc # keepassxc keepassxc-cli keepassxc-proxy
          # gparted # Graphical disk partitioning tool
          # figlet # Program for making large letters out of ordinary text
          # imagemagick # A software suite to create, edit, compose, or convert bitmap images
          # deepin.deepin-calculator # An easy to use calculator for ordinary users
        ]);

      # plasma5 = {
      #   excludePackages = with pkgs // pkgs.libsForQt5; [
      #     elisa
      #     khelpcenter
      #     # konsole
      #     oxygen
      #   ];
      # };
      plasma6 = {
        excludePackages = with pkgs // pkgs.libsForQt5; [
          elisa
          khelpcenter
          # konsole
          oxygen
        ];
      };

      # sessionVariables = mkIf (config.features.graphics.backend == "wayland") {
      #   NIXOS_OZONE_WL = "1";
      #   MOZ_ENABLE_WAYLAND = "1";
      # };

      variables = mkIf (config.features.graphics.backend == "wayland" && config.features.graphics.gpu == "hybrid-nvidia") {
        NVD_GPU = 1;
      };
    };

    security = {
      pam.services.kwallet = {
        name = "kwallet";
        enableKwallet = true;
      };
    };
    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs // pkgs.kdePackages; [
          xdg-desktop-portal-kde
          xdg-desktop-portal-gtk
        ];
        config = {
          default = {
            kde = [ "kde" "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "xdg-desktop-portal-kde" ];
          };
        };
      };
    };
  };
}
