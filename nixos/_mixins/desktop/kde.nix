{ config, lib, pkgs, username, ... }:
{

  programs = {
    kdeconnect = {
      # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };

  services = {
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "plasmawayland";
        sddm = {
          enable = true; # Display Manager
          autoNumlock = true;

          settings = {
            Theme = {
              CursorTheme = "layan-border_cursors";
            };
          };
        };
        # defaultSession = "plasmawayland";
      };
      desktopManager.plasma5 = {
        enable = true; # Desktop Environment
      };
      # videoDrivers = [
      # "fbdev" # The fbdev (Framebuffer Device) driver is a generic framebuffer driver that provides access to the frame buffer of the display hardware.
      # "modesetting"     # The modesetting driver is a generic driver for modern video hardware that relies on kernel modesetting (KMS) to set the display modes and manage resolution and refresh rate.
      # "amdgpu"          # This is the open-source kernel driver for AMD graphics cards. It's part of the AMDGPU driver stack and provides support for newer AMD GPUs.
      # "nouveau"         # Nouveau is an open-source driver for NVIDIA graphics cards. It aims to provide support for NVIDIA GPUs and is an alternative to the proprietary NVIDIA driver
      # "radeon"          # The Radeon driver is an open-source driver for AMD Radeon graphics cards. It provides support for older AMD GPUs.
      # ];
    };
  };

  # gtk = lib.mkDefault {
  #   enable = true;

  #   iconTheme.package = pkgs.catppuccin-papirus-folders.override {
  #     flavor = "mocha";
  #     accent = "mauve";
  #   };
  #   iconTheme.name = "Papirus-Dark";

  #   theme.package = pkgs.catppuccin-gtk.override {
  #     accents = [ "mauve" ];
  #     size = "standard";
  #     tweaks = [ "rimless" ];
  #     variant = "mocha";
  #   };
  #   theme.name = "Catppuccin-Mocha-Standard-Mauve-dark";

  #   cursorTheme.package = pkgs.catppuccin-cursors.mochaDark;
  #   cursorTheme.name = "Catppuccin-Mocha-Dark-Cursors";
  #   cursorTheme.size = 24;

  #   font.name = "Iosevka Comfy";
  # };

  # qt = lib.mkDefault {
  #   enable = true;
  #   platformTheme = "gtk2";
  #   # style = {
  #   #   # name = "Adwaita-dark";
  #   #   package = pkgs.adwaita-qt;
  #   # };
  # };

  environment = {
    systemPackages = (with pkgs.libsForQt5; [
      # System-Wide Packages
      bismuth # Dynamic Tiling
      packagekit-qt # Package Updater
      kaccounts-integration
      kaccounts-providers
    ]) ++ (with pkgs; [
      libportal-qt5
      plasma-overdose-kde-theme

      # Archive Utilities
      atool # apack arepack als adiff atool aunpack acat
      gzip # gunzip zmore zegrep zfgrep zdiff zcmp uncompress gzip znew zless zcat zforce gzexe zgrep
      lz4 # lz4c lz4 unlz4 lz4cat
      lzip # lzip
      lzo # Real-time data (de)compression library
      lzop # lzop
      p7zip # 7zr 7z 7za
      rar # Utility for RAR archives
      rzip # rzip
      unzip # zipinfo unzipsfx zipgrep funzip unzip
      xz # lzfgrep lzgrep lzma xzegrep xz unlzma lzegrep lzmainfo lzcat xzcat xzfgrep xzdiff lzmore xzgrep xzdec lzdiff xzcmp lzmadec xzless xzmore unxz lzless lzcmp
      zip # zipsplit zipnote zip zipcloak
      zstd # zstd pzstd zstdcat zstdgrep zstdless unzstd zstdmt

      # Multimedia Utilities
      ffmpeg # ffprobe ffmpeg
      ffmpegthumbnailer # ffmpegthumbnailer
      libdvdcss # A library for decrypting DVDs
      libdvdread # A library for reading DVDs
      libopus
      libvorbis
      mediainfo # mediainfo
      mpg123 # out123 conplay mpg123-id3dump mpg123 mpg123-strip
      mplayer # gmplayer mplayer mencoder
      mpv
      ocamlPackages.gstreamer # mpv mpv_identify.sh umpv
      simplescreenrecorder # ssr-glinject simplescreenrecorder
      video-trimmer # video-trimmer

      qt6Packages.qtstyleplugin-kvantum

      # Miscellaneous:
      variety # A wallpaper manager for Linux systems

      # Picture manger
      digikam # Photo Management Program
      shotwell # Popular photo organizer for the GNOME desktop

      # KDE Plasma tools
      kdiff3 # Compares and merges 2 or 3 files or directories
      ark # Graphical file compression/decompression utility
      filelight # Disk usage statistics
      kate # Advanced text editor
      kcalc # Scientific calculator
      kgpg # A KDE based interface for GnuPG, a powerful encryption utility
      krename

      keepassxc # keepassxc keepassxc-cli keepassxc-proxy
      gparted # Graphical disk partitioning tool
      figlet # Program for making large letters out of ordinary text
      imagemagick # A software suite to create, edit, compose, or convert bitmap images
      deepin.deepin-calculator # An easy to use calculator for ordinary users
    ]);

    plasma5.excludePackages = with pkgs.libsForQt5; [
      elisa
      khelpcenter
      # konsole
      oxygen
    ];

    sessionVariables = {
      #NIXOS_OZONE_WL = "1";
      #MOZ_ENABLE_WAYLAND = "1";
    };
  };
  xdg = lib.mkDefault {
    portal = {
      # extraPortals = pkgs.xdg-desktop-portal-kde;
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
        kde = {
          default = [
            "xdg-desktop-portal-kde"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [
            "xdg-desktop-portal-kde"
          ];
        };
      };
    };
  };

  sound.mediaKeys.enable = true;
}
