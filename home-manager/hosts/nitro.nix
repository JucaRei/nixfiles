{ config, lib, pkgs, ... }:
let
  # inherit (lib) lib;
  font-search = pkgs.writeShellScriptBin "font-search" ''
    fc-list \
        | grep -ioE ": [^:]*$1[^:]+:" \
        | sed -E 's/(^: |:)//g' \
        | tr , \\n \
        | sort \
        | uniq
  '';

  file-manager = "thunar.desktop";
  compressed = "engrampa.desktop";
  # browser = "vivaldi-stable.desktop";
  # browser = "firefox.desktop";
  # browser = "brave-browser.desktop";
  browser = "floorp.desktop";
  # viewer = "org.xfce.ristretto.desktop";
  pdf = "org.pwmt.zathura.desktop";
  video = "umpv.desktop";
  audio = "org.gnome.Rhythmbox3.desktop";
  text = "org.gnome.gedit.desktop";
  image = "feh.desktop";
  word = "writer.desktop";
  excel = "calc.desktop";
  powerpoint = "impress.desktop";
in
# with test;
with lib;
{
  imports = [
    # ../_mixins/console/neovim.nix
    ../_mixins/apps/video/mpv/mpv.nix
    # ../_mixins/apps/tools/transmission.nix
    ../_mixins/dev/nix.nix
    # ../_mixins/console/aria2.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    #../_mixins/apps/text-editor/vscode.nix
    ../_mixins/apps/text-editor/vscode/vscode.nix
    ../_mixins/apps/documents/zathura.nix
    # ../_mixins/apps/terminal/urxvt.nix
    # ../_mixins/apps/browser/floorp.nix
    # ../_mixins/apps/browser/firefox/firefox.nix
    ../_mixins/apps/browser/brave
    # ../_mixins/apps/browser/firefox/librewolf.nix
    # ../_mixins/services/flatpak.nix
    # ../_mixins/apps/text-editor/sublime.nix
  ];
  # dconf.settings = {
  #   "org/gnome/desktop/background" = {
  #     picture-options = "zoom";
  #     # picture-uri = "file://${config.home.homeDirectory}/Pictures/Determinate/DeterminateColorway-3440x1440.png";
  #   };
  # };

  config = {
    # Cinnamon
    mime.defaultApps = {
      enable = true;
      defaultBrowser = "floorp.desktop";
      defaultFileManager = "nemo.desktop";
      defaultVideoPlayer = "mpv.desktop";
      defaultPdf = "org.pwmt.zathura.desktop";
      defaultPlainText = "org.gnome.gedit.desktop";
      defaultImgViewer = "xviewer.desktop";
      defaultArchiver = " org.gnome.FileRoller.desktop";
    };
    home = {
      packages = with pkgs; [
        # spotdl
        # whatsapp-for-linux # Whatsapp desktop messaging app
        # icloud-photo-downloader
        # (nixGLWrap pkgs vlc)
        # cloneit
        # deezer-gui
        # fantezy
        transmission_4-gtk
        nix-whereis
        unstable.spotube
        libreoffice-fresh
        # nf-iosevka
        gedit
        neovim
        font-search
        unstable.obsidian
        # fcitx5-with-addons
        # vv
        # gparted
        # tmux
      ];

      sessionVariables = {
        # GBM_BACKEND = "nvidia-drm";
        # GBM_BACKEND = "nvidia";
        # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

      keyboard = lib.mkForce {
        # layout = "br,us";
        layout = lib.mkForce "br";
        model = lib.mkForce "pc105"; # "pc104alt";
        # options = [
        # "grp:shifts_toggle"
        # "eurosign:e"
        # ];
        # variant = "abnt2";
        # variant = "nodeadkeys"; # "nodeadkeys";
        # variant = # "intl"/ "alt-intl" / "altgr-intl"
        #/ "mac" / # "mac_nodeadkeys"
      };

      # file.".config/testingFOLDER/testing.txt".text = ''
      #   ${testing}
      # '';
    };

    services = mkForce {
      bash.enable = true;
      starship.enable = true;
      eza.enable = false;
      lsd.enable = true;
      # firefox.enable = true;
      # flatpak-nix.enable = true;
      yt-dlp-custom.enable = true;
      brave.enable = true;
      # properties.enable = false;
      # vscode-server = {
      #   # enable = lib.mkForce true;
      #   enableFHS = lib.mkForce true;
      #   nodejsPackage = pkgs.nodejs-18_x;
      #   # extraRuntimeDependencies = pkgs: with pkgs; [
      #   #   nixpkgs-fmt # formatter
      #   #   nix-output-monitor # better output from builds
      #   #   nil # lsp server
      #   #   nix-direnv # A shell extension that manages your environment for nix
      #   #   git # versioning
      #   #   wget
      #   #   curl
      #   # ];
      # };

      # aria2.enable = true;
      # flatpak.packages = [
      #   # "flathub:app/dev.aunetx.deezer/x86_64/stable"
      #   "flathub:app/com.rtosta.zapzap/x86_64/stable"
      # ];
    };

    programs = {
      # yt-dlp.enable = true;
    };
    dconf.settings = {
      # "org/gnome/desktop/interface" = {
      #   show-battery-percentage = true;
      # };

      # Virtmanager
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
    # modules.desktop.browsers.chromium.enable = true;
    nix.settings = {
      extra-substituters = [ "https://nitro.cachix.org" ];
      extra-trusted-public-keys = [ "nitro.cachix.org-1:Z4AoDBOqfAdBlAGBCoyEZuwIQI9pY+e4amZwP94RU0U=" ];
    };

    # xdg = {
    #   # force overwrite of mimeapps.list, since it will be manipulated by some desktop apps without asking
    #   configFile."mimeapps.list".force = true;
    #   mimeApps = {
    #     enable = true;
    #     # verify using `xdg-mime query default <mimetype>`
    #     associations.added = lib.mkForce {
    #       "inode/directory" = file-manager;

    #       "text/html" = browser;
    #       "text/xml" = browser;
    #       "x-scheme-handler/http" = browser;
    #       "x-scheme-handler/https" = browser;
    #       "x-scheme-handler/mailto" = browser; # TODO
    #       "x-scheme-handler/chrome" = browser;
    #       "application/x-extension-htm" = browser;
    #       "application/x-extension-html" = browser;
    #       "application/x-extension-shtml" = browser;
    #       "application/xhtml+xml" = browser;
    #       "application/x-extension-xhtml" = browser;
    #       "application/x-extension-xht" = browser;

    #       "application/pdf" = pdf;
    #       "text/plain" = text;

    #       "image/gif" = image;
    #       "image/heic" = image;
    #       "image/jpeg" = image;
    #       "image/png" = image;

    #       "x-scheme-handler/msteams" = [ "teams.desktop" ];

    #       # Compression
    #       "application/bzip2" = compressed;
    #       "application/gzip" = compressed;
    #       "application/vnd.rar" = compressed;
    #       "application/x-7z-compressed" = compressed;
    #       "application/x-7z-compressed-tar" = compressed;
    #       "application/x-bzip" = compressed;
    #       "application/x-bzip-compressed-tar" = compressed;
    #       "application/x-compress" = compressed;
    #       "application/x-compressed-tar" = compressed;
    #       "application/x-cpio" = compressed;
    #       "application/x-gzip" = compressed;
    #       "application/x-lha" = compressed;
    #       "application/x-lzip" = compressed;
    #       "application/x-lzip-compressed-tar" = compressed;
    #       "application/x-lzma" = compressed;
    #       "application/x-lzma-compressed-tar" = compressed;
    #       "application/x-tar" = compressed;
    #       "application/x-tarz" = compressed;
    #       "application/x-xar" = compressed;
    #       "application/x-xz" = compressed;
    #       "application/x-xz-compressed-tar" = compressed;
    #       "application/zip" = compressed;

    #       "application/vnd.jgraph.mxfile" = [ "drawio.desktop" ];
    #       "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = word;
    #       "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = excel;
    #       "application/vnd.openxmlformats-officedocument.presentationml.presentation" = powerpoint;
    #       "application/msword" = word;
    #       "application/msexcel" = excel;
    #       "application/mspowerpoint" = powerpoint;
    #       "application/vnd.oasis.opendocument.text" = word;
    #       "application/vnd.oasis.opendocument.spreadsheet" = excel;
    #       "application/vnd.oasis.opendocument.presentation" = powerpoint;
    #     };
    #     defaultApplications = lib.mkForce {
    #       "inode/directory" = file-manager;

    #       "text/html" = browser;
    #       "text/xml" = browser;
    #       "x-scheme-handler/http" = browser;
    #       "x-scheme-handler/https" = browser;
    #       "x-scheme-handler/mailto" = browser; # TODO
    #       "x-scheme-handler/chrome" = browser;
    #       "application/x-extension-htm" = browser;
    #       "application/x-extension-html" = browser;
    #       "application/x-extension-shtml" = browser;
    #       "application/xhtml+xml" = browser;
    #       "application/x-extension-xhtml" = browser;
    #       "application/x-extension-xht" = browser;

    #       "application/pdf" = pdf;
    #       "text/plain" = text;

    #       "image/gif" = image;
    #       "image/heic" = image;
    #       "image/jpeg" = image;
    #       "image/png" = image;

    #       "x-scheme-handler/msteams" = [ "teams.desktop" ];

    #       # Compression
    #       "application/bzip2" = compressed;
    #       "application/gzip" = compressed;
    #       "application/vnd.rar" = compressed;
    #       "application/x-7z-compressed" = compressed;
    #       "application/x-7z-compressed-tar" = compressed;
    #       "application/x-bzip" = compressed;
    #       "application/x-bzip-compressed-tar" = compressed;
    #       "application/x-compress" = compressed;
    #       "application/x-compressed-tar" = compressed;
    #       "application/x-cpio" = compressed;
    #       "application/x-gzip" = compressed;
    #       "application/x-lha" = compressed;
    #       "application/x-lzip" = compressed;
    #       "application/x-lzip-compressed-tar" = compressed;
    #       "application/x-lzma" = compressed;
    #       "application/x-lzma-compressed-tar" = compressed;
    #       "application/x-tar" = compressed;
    #       "application/x-tarz" = compressed;
    #       "application/x-xar" = compressed;
    #       "application/x-xz" = compressed;
    #       "application/x-xz-compressed-tar" = compressed;
    #       "application/zip" = compressed;

    #       "application/vnd.jgraph.mxfile" = [ "drawio.desktop" ];
    #       "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = word;
    #       "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = excel;
    #       "application/vnd.openxmlformats-officedocument.presentationml.presentation" = powerpoint;
    #       "application/msword" = word;
    #       "application/msexcel" = excel;
    #       "application/mspowerpoint" = powerpoint;
    #       "application/vnd.oasis.opendocument.text" = word;
    #       "application/vnd.oasis.opendocument.spreadsheet" = excel;
    #       "application/vnd.oasis.opendocument.presentation" = powerpoint;
    #     };
    #   };
    # };
  };
}
