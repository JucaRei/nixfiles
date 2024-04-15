{ pkgs, config, lib, ... }:
let
  # nixGL = (import
  #   (builtins.fetchGit {
  #     url = "http://github.com/guibou/nixGL";
  #     ref = "refs/heads/backport/noGLVND";
  #   })
  #   { enable32bits = true; }).auto;
  nixGL-old = import ../../lib/nixGL-old.nix { inherit config pkgs; };
  nixGL = import ../../lib/nixGL.nix { inherit config pkgs; };
  non-nixos = config.services.nonNixOs;
in
{
  imports = [
    ../_mixins/non-nixos
    # ../_mixins/apps/browser/firefox/firefox.nix
  ];
  config = {
    home.packages = with pkgs; [

    ] ++ (lib.mkIf non-nixos.enable (with pkgs.nixGL;[
      firefox
    ]));
    services.nonNixOs.enable = true;
    nix.settings = {
      extra-substituters = [ "https://juca-nixfiles.cachix.org" ];
      extra-trusted-public-keys = [
        "juca-nixfiles.cachix.org-1:HN1wk6GxLI1ZPr3bN2RNa+a4jXwLGUPJG6zXKqDZ/Kc="
      ];
    };
  };
}
