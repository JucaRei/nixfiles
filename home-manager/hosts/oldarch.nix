{ pkgs, config, lib, system, ... }:
let
  nixGL = (import
    (builtins.fetchGit {
      url = "http://github.com/guibou/nixGL";
      ref = "refs/heads/backport/noGLVND";
    })).auto;
  # })
  # { enable32bits = true; }).auto;
  # nixGL-old = import ../../lib/nixGL-old.nix { inherit config pkgs; };
  # nixGL = import ../../lib/nixGL.nix { inherit config pkgs; };
  # non-nixos = config.custom.nonNixOs;

  font-search = pkgs.writeShellScriptBin "font-search" ''
    fc-list \
        | grep -ioE ": [^:]*$1[^:]+:" \
        | sed -E 's/(^: |:)//g' \
        | tr , \\n \
        | sort \
        | uniq
  '';

  oldGL = import ../../lib/oldGL.nix { inherit config pkgs; };


  nixGLWrapper = package: pkgs.stdenvNoCC.mkDerivation {
    inherit (package) pname version meta;
    doCheck = false;
    dontUnpack = true;
    dontBuild = true;
    installPhase =
      let
        script = ''
          #!/bin/sh
          exec ${nixGL.packages.${system}.nixGLNvidia}/bin/nixGLNvidia ${package}/bin/${package.pname} "$@"
        '';
      in
      ''
        mkdir -p $out/bin
        printf '${script}' > $out/bin/${package.pname}
        chmod +x $out/bin/${package.pname}
        mkdir -p $out/share
        ${pkgs.xorg.lndir}/bin/lndir -silent ${package}/share $out/share
      '';
  };

in
{
  imports = [
    ../_mixins/non-nixos
    # ../_mixins/apps/browser/firefox/firefox.nix
    ../_mixins/console/bash
    ../_mixins/console/yt-dlp
    # ../_mixins/services/podman.nix
    ../_mixins/services/virt.nix

  ];
  config = {
    home.packages = with pkgs; [
      # (nixGL.override { useGLVND = false; } vlc)
      cloneit
      font-search
      vimix-gtk-themes
      # (oldGL thorium)
    ];
    custom = {
      nonNixOs.enable = true;
    };
    services = {
      yt-dlp-custom.enable = true;
      bash.enable = true;
      # podman.enable = false;
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
