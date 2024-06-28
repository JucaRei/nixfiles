{ pkgs, config, lib, ... }:
let
  # nixGL = (import
  #   (builtins.fetchGit {
  #     url = "http://github.com/guibou/nixGL";
  #     ref = "refs/heads/backport/noGLVND";
  #   })
  #   { enable32bits = true; }).auto;
  # nixGL-old = import ../../lib/nixGL-old.nix { inherit config pkgs; };
  # nixGL = import ../../lib/nixGL.nix { inherit config pkgs; };
  # non-nixos = config.services.nonNixOs;

  font-search = pkgs.writeShellScriptBin "font-search" ''
    fc-list \
        | grep -ioE ": [^:]*$1[^:]+:" \
        | sed -E 's/(^: |:)//g' \
        | tr , \\n \
        | sort \
        | uniq
  '';

in
{
  imports = [
    ../_mixins/non-nixos
    # ../_mixins/apps/browser/firefox/firefox.nix
    ../_mixins/console/bash
    ../_mixins/console/yt-dlp
    ../_mixins/services/podman.nix
    ../_mixins/services/virt.nix

  ];
  config = {
    home.packages = with pkgs; [
      # (nixGL.override { useGLVND = false; } vlc)
      cloneit
      font-search
      vimix-gtk-themes
    ];
    services = {
      nonNixOs.enable = true;
      yt-dlp-custom.enable = true;
      bash.enable = true;
      podman.enable = false;
      virt.libvirt.enable = false;
    };
    nix.settings = {
      extra-substituters = [ "https://juca-nixfiles.cachix.org" ];
      extra-trusted-public-keys = [
        "juca-nixfiles.cachix.org-1:HN1wk6GxLI1ZPr3bN2RNa+a4jXwLGUPJG6zXKqDZ/Kc="
      ];
    };
  };
}
