{ config, lib, pkgs, username, inputs, nixgl, ... }:
with lib;
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  cfg = config.services.nonNixOs;
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
        (import nixgl { inherit pkgs; }).nixGLIntel # OpenGL for GUI apps
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
