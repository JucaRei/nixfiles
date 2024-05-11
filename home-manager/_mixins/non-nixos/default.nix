{ config, lib, pkgs, username, nixgl, nixpkgs, ... }:
with lib;
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  cfg = config.services.nonNixOs;
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = [ nixgl.overlay ];
  };
in
{
  options.services.nonNixOs = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        # niv
        # nix
        # nixgl.auto.nixGLDefault
        nix-output-monitor
        nixpkgs-fmt
        nil
        nixGL.auto.nixGLDefault # OpenGL for GUI apps
        # alejandra
        # rnix-lsp
        # base-packages
        # fzf
        # tmux
      ];

      # file.".config/nix/nix.conf".text = ''
      #   experimental-features = nix-command flakes
      # '';
      # extraProfileCommands = ''
      #   if [[ -d "$out/share/applications" ]] ; then
      #     ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
      #   fi
      # '';
    };
    targets.genericLinux.enable = true;
  };
}
