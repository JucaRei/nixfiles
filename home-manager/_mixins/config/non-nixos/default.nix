{ config, lib, pkgs, sources, nixpkgs, ... }:

with lib;
let cfg = config.modules.nonNixOs;
in {
  options.modules.nonNixOs = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      # nix
      niv
      nix
      nix-index
      nix-index-update
      nixpkgs-fmt
      rnix-lsp
      # base-packages
      fzf
      # tmux
    ];

    home.file.".config/nix/nix.conf".text = ''
      experimental-features = nix-command flakes
    '';
    systemd.user.tmpfiles.rules =
      [ "L+  %h/.nix-defexpr/nixos  -  -  -  -  ${nixpkgs}" ];
  };
}
