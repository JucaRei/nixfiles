{ config, lib, pkgs, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    # ../_mixins/console/neovim.nix
    ../../_mixins/apps/video/mpv/mpv.nix
    ../../_mixins/apps/browser/chrome-based-browser.nix
    ../../_mixins/apps/browser/firefox-based-browser.nix
    # ../_mixins/apps/tools/transmission.nix
    ../../_mixins/dev/nix.nix
    # ../_mixins/console/aria2.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    #../_mixins/apps/text-editor/vscode.nix
    ../../_mixins/apps/text-editor/vscode/vscode.nix
    ../../_mixins/apps/documents/zathura.nix
    # ../_mixins/apps/terminal/urxvt.nix
    # ../_mixins/apps/browser/floorp.nix
    # ../_mixins/apps/browser/firefox/firefox.nix
    # ../../_mixins/apps/browser/brave
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
    custom = {
      features = {
        # Cinnamon
        mime.defaultApps = {
          enable = true;
          defaultBrowser = "floorp.desktop";
          defaultFileManager = "nemo.desktop";
          defaultAudioPlayer = "io.bassi.Amberol.desktop";
          defaultVideoPlayer = "mpv.desktop";
          defaultPdf = "org.pwmt.zathura.desktop";
          defaultPlainText = "org.gnome.gedit.desktop";
          defaultImgViewer = "xviewer.desktop";
          defaultArchiver = "org.gnome.FileRoller.desktop";
          defaultExcel = "calc.desktop";
          defaultWord = "writer.desktop";
          defaultPowerPoint = "impress.desktop";
          defaultEmail = "org.gnome.Geary.desktop";
        };
      };
      console = {
        bash.enable = true;
        starship.enable = true;
        eza.enable = false;
        lsd.enable = true;
        # firefox.enable = true;
        # flatpak-nix.enable = true;
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
        git.enable = true;
        gpg.enable = true;
        ncmpcpp.enable = false;
        mpd.enable = true;
        yt-dlp-custom.enable = mkForce true;
      };

      apps = {
        chrome-based-browser = {
          enable = true;
          browser = "brave";
          disableWayland = true;
        };
        # firefox-based-browser = {
        #   enable = true;
        #   browser = "firefox-devedition";
        # };
      };
    };

    home = {
      packages = with pkgs; [
        # spotdl
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
        amberol
        gnome.geary
        neovim
        unstable.obsidian
        # fcitx5-with-addons
        # vv
        gparted
        # tmux
      ];

      sessionVariables = {
        # GBM_BACKEND = "nvidia-drm";
        # GBM_BACKEND = "nvidia";
        # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

      keyboard = mkForce {
        # layout = "br,us";
        layout = mkForce "br";
        model = mkForce "pc105"; # "pc104alt";
        # options = [
        # "grp:shifts_toggle"
        # "eurosign:e"
        # ];
        # variant = "abnt2";
        # variant = "nodeadkeys"; # "nodeadkeys";
        # variant = # "intl"/ "alt-intl" / "altgr-intl"
        #/ "mac" / # "mac_nodeadkeys"
      };
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
  };
}
