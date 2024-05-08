{ pkgs, config, lib, username, ... }:
with lib.hm.gvariant;
let
  nixGL = import ../../lib/nixGL.nix { inherit config pkgs; };
  # mpv-custom = import ../_mixins/apps/video/mpv.nix;
  vivaldi-custom = pkgs.vivaldi.override {
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
  browser = "firefox.desktop";
  viewer = "org.xfce.ristretto.desktop";
  video = "umpv.desktop";
  audio = "org.gnome.Rhythmbox3.desktop";
in
{
  imports = [
    # ../_mixins/apps/music/rhythmbox.nix
    # ../_mixins/apps/text-editor/vscode.nix
    # ../_mixins/apps/text-editor/vscodium.nix
    # ../_mixins/apps/terminal/alacritty.nix
    ../_mixins/console/bash.nix
    # ../_mixins/apps/browser/firefox/librewolf.nix
    ../_mixins/apps/browser/firefox/firefox.nix
    ../_mixins/apps/video/mpv/mpv-unwrapped.nix
    ../_mixins/apps/documents/libreoffice.nix
    ../_mixins/apps/text-editor/vscode/vscode-unwrapped.nix
    ../_mixins/services/podman.nix
    ../_mixins/console/yt-dlp.nix
    ../_mixins/non-nixos
    # ../_mixins/apps/tools/zathura.nix
    # ../_mixins/desktop/bspwm/themes/default
    # ../_mixins/apps/browser/opera.nix
  ];
  config = {
    nix.settings = {
      cores = 2;
      extra-substituters = [ "https://anubis.cachix.org" ];
      extra-trusted-public-keys = [ "anubis.cachix.org-1:p6q0lqdZcE9UrkmFonRSlRPAPADFnZB1atSgp6tbF3U=" ];
    };

    services = {
      bash.enable = true;
      nonNixOs.enable = true;
      udiskie = {
        enable = true;
        automount = true;
      };
      firefox.enable = true;
      podman.enable = false;
      yt-dlp-custom.enable = true;
    };
    home = {
      packages = with pkgs; [
        # docker-client
        font-search
        guvcview
        cloneit
        podman-compose
        # (nixGL vivaldi-custom)
        (nixGL thorium)
      ];
      sessionVariables = {
        BROWSER = "firefox";
        NO_AT_BRIDGE = 1; # at-spi2-core
      };
      file = {
        # "bin/create-docker" = {
        #   enable = true;
        #   executable = true;
        #   text = ''
        #     #!/usr/bin/env bash
        #     ${pkgs.lima}/bin/limactl list | grep default | grep -q Running || ${pkgs.lima}/bin/limactl start --name=default template://docker # Start/create default lima instance if not running/created
        #     ${pkgs.docker-client}/bin/docker context create lima-default --docker "host=unix:///Users/${username}/.lima/default/sock/docker.sock"
        #     ${pkgs.docker-client}/bin/docker context use lima-default
        #   '';
        # };
        # "bin/home-switch" = {
        #   enable = true;
        #   executable = true;
        #   text = ''
        #     #!/usr/bin/env bash
        #     # git clone --depth=1 -b cleanup https://github.com/JucaRei/nixfiles ~/opt/nixos-configs &>/dev/null || true
        #     git clone --depth=1 -b cleanup https://github.com/JucaRei/nixfiles ~/.dotfiles/nixfiles &>/dev/null || true
        #     # git -C ~/opt/nixos-configs pull origin master --rebase
        #     ## OS-specific support (mostly, Ubuntu vs anything else)
        #     ## Anything else will use nixpkgs-unstable
        #     EXTRA_ARGS=""
        #     if grep -iq Ubuntu /etc/os-release
        #     then
        #       version="$(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')"
        #       ## Support for Ubuntu 22.04
        #       if [[ "$version" == "22.04" ]]
        #       then
        #         EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-22.05"
        #       fi
        #       ## TODO: Support Ubuntu 24.04 when released
        #     fi
        #     nix --extra-experimental-features 'nix-command flakes' run "$HOME/opt/nixos-configs#homeConfigurations.heywoodlh.activationPackage" --impure $EXTRA_ARGS
        #   '';
        # };
      };
    };
    xdg = {
      mimeApps = {
        defaultApplications = {
          "inode/directory" = file-manager;
          "text/html" = browser;
          "text/xml" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/mailto" = browser; # TODO
          "x-scheme-handler/chrome" = browser;
          "application/x-extension-htm" = browser;
          "application/x-extension-html" = browser;
          "application/x-extension-shtml" = browser;
          "application/xhtml+xml" = browser;
          "application/x-extension-xhtml" = browser;
          "application/x-extension-xht" = browser;

          # Compression
          "application/bzip2" = compressed;
          "application/gzip" = compressed;
          "application/vnd.rar" = compressed;
          "application/x-7z-compressed" = compressed;
          "application/x-7z-compressed-tar" = compressed;
          "application/x-bzip" = compressed;
          "application/x-bzip-compressed-tar" = compressed;
          "application/x-compress" = compressed;
          "application/x-compressed-tar" = compressed;
          "application/x-cpio" = compressed;
          "application/x-gzip" = compressed;
          "application/x-lha" = compressed;
          "application/x-lzip" = compressed;
          "application/x-lzip-compressed-tar" = compressed;
          "application/x-lzma" = compressed;
          "application/x-lzma-compressed-tar" = compressed;
          "application/x-tar" = compressed;
          "application/x-tarz" = compressed;
          "application/x-xar" = compressed;
          "application/x-xz" = compressed;
          "application/x-xz-compressed-tar" = compressed;
          "application/zip" = compressed;
        };
      };
    };
  };
}
