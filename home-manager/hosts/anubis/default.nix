{ pkgs, config, lib, username, ... }:
with lib.hm.gvariant;
let
  nixGL = import ../../../lib/nixGL.nix { inherit config pkgs; };
  # mpv-custom = import ../_mixins/apps/video/mpv.nix;
  vivaldi-custom = pkgs.unstable.vivaldi.override {
    proprietaryCodecs = true;
    enableWidevine = false;
    # qt = "qt6";
  };
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
  browser = "thorium-browser.desktop";
  viewer = "org.xfce.ristretto.desktop";
  pdf = "org.pwmt.zathura.desktop";
  video = "umpv.desktop";
  audio = "org.gnome.Rhythmbox3.desktop";
  text = "org.xfce.mousepad.desktop";
  image = "feh.desktop";
  word = "writer.desktop";
  excel = "calc.desktop";
  powerpoint = "impress.desktop";

  isVM = pkgs.writeShellScriptBin "isVM" ''
    !#/usr/bin/env bash

    pgrep -f "${pkgs.xorg.xrandr}/bin/xrandr --query | grep '^Virtual-1 connected'"
  '';
  # ${pkgs.procps}/bin/pgrep -f "${pkgs.xorg.xrandr}/bin/xrandr --query | ${pkgs.gnugrep}/bin/grep '^Virtual-1 connected'" > /dev/null && echo 'true' || echo 'false'
in
{
  imports = [
    # ../../_mixins/apps/music/rhythmbox.nix
    # ../../_mixins/apps/text-editor/vscode.nix
    # ../../_mixins/apps/text-editor/vscodium.nix
    # ../../_mixins/apps/terminal/alacritty.nix
    # ../../_mixins/apps/browser/firefox/librewolf.nix
    # ../../_mixins/apps/browser/firefox/firefox.nix
    # ../../_mixins/apps/browser/opera
    ../../_mixins/apps/browser/chrome-based-browser.nix
    ../../_mixins/apps/browser/firefox-based-browser.nix
    ../../_mixins/apps/video/mpv/mpv-unwrapped.nix
    ../../_mixins/apps/documents/libreoffice.nix
    ../../_mixins/apps/text-editor/vscode
    ../../_mixins/services/podman.nix
    ../../_mixins/services/polkit-agent.nix
    # ../../_mixins/non-nixos
    # ../../_mixins/apps/tools/zathura.nix
    # ../../_mixins/desktop/bspwm/themes/default
    # ../../_mixins/apps/browser/opera.nix
  ];
  config = {
    nix.settings = {
      cores = 2;
      extra-substituters = [ "https://anubis.cachix.org" ];
      extra-trusted-public-keys = [ "anubis.cachix.org-1:p6q0lqdZcE9UrkmFonRSlRPAPADFnZB1atSgp6tbF3U=" ];
    };

    custom = {
      features = {
        nonNixOs.enable = true;
        mime.defaultApps = {
          enable = lib.mkForce true;
          defaultBrowser = "vivaldi.desktop";
          defaultFileManager = "thunar.desktop";
          defaultAudioPlayer = "org.gnome.Rhythmbox3.desktop";
          defaultVideoPlayer = "mpv.desktop";
          defaultPdf = "org.pwmt.zathura.desktop";
          defaultPlainText = "org.xfce.mousepad.desktop";
          defaultImgViewer = "feh.desktop";
          defaultArchiver = "engrampa.desktop";
          defaultExcel = "calc.desktop";
          defaultWord = "writer.desktop";
          defaultPowerPoint = "impress.desktop";
          defaultEmail = "org.gnome.Geary.desktop";
        };
      };

      apps = {
        firefox-based-browser = {
          enable = true;
          browser = "firefox";
          disableWayland = true;
        };
        chrome-based-browser = {
          enable = true;
          browser = "brave";
          disableWayland = true;
        };
        vscode.enable = true;
      };

      services = {
        podman.enable = false;
      };

      programs = {
        yt-dlp-custom.enable = true;
      };

      console = {
        fish.enable = true;
        bash.enable = true;
        # udiskie = {
        #   enable = true;
        #   automount = true;
        # };
      };
    };

    services.vscode-server = {
      enable = true;
      nodejsPackage = pkgs.nodejs-18_x;
    };

    i18n =
      if ("${pkgs.xorg.xrandr}/bin/xrandr --query | grep '^Virtual-1 connected'" != true) then {
        glibcLocales = pkgs.glibcLocales.override {
          allLocales = false;
          locales = [
            "en_US.UTF-8/UTF-8"
            "pt_BR.UTF-8/UTF-8"
          ];

        };
        # inputMethod = {
        #   enabled = "fcitx5";
        #   fcitx5.addons = with pkgs; [
        #     fcitx5-rime
        #   ];
        # };
      } else "";

    home =
      let
        thorium-va = pkgs.thorium.override
          {
            # enable hardware accerlation with vaapi
            commandLineArgs = [
              "--enable-features=VaapiVideoEncoder,VaapiVideoDecoder"
              "--enable-chrome-browser-cloud-management"
            ];
          };
      in
      {

        packages = with pkgs;
          [
            # docker-client
            font-search
            libva-utils
            guvcview
            cloneit
            # neovim
            docker-compose
            obsidian
            xfce.mousepad
            spotube
            nixos-tweaker
            transmission_4-gtk
            (nixGL vivaldi-custom)
            # (nixGL thorium-va)
          ];

        sessionVariables = {
          BROWSER = "firefox"; # "thorium";
          NO_AT_BRIDGE = 1; # at-spi2-core
        };

        keyboard =
          # if (isNull != true) then {
          if ("${pkgs.xorg.xrandr}/bin/xrandr --query | ${pkgs.gnugrep}/bin/grep '^Virtual-1 connected'" != true) then {
            # layout = "br,us";
            layout = "us";
            model = "pc105"; # "pc104alt";
            variant = "mac";
            # options = [
            # "grp:shifts_toggle"
            # "eurosign:e"
            # ];
            # variant = "abnt2";
            # variant = "nodeadkeys"; # "nodeadkeys";
            # variant = # "intl"/ "alt-intl" / "altgr-intl"
            #/ "mac" / # "mac_nodeadkeys"
          } else {
            layout = "br";
            model = "pc105";
            variant = "abnt2";
          };

        file = { };
      };
  };
}

# echo ~/.nix-profile/bin/fish | sudo tee -a /etc/shells
# usermod -s ~/.nix-profile/bin/fish $USER
