{ config, lib, pkgs, username, ... }:
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
    xdg = lib.mkForce {
      enable = true;
      mime = { enable = true; };
      systemDirs.data =
        if isDarwin
        then [ "/Users/${username}/.nix-profile/share/applications" ]
        else [ "/home/${username}/.nix-profile/share/applications" ];
    };
    home = {
      packages = with pkgs; [
        # niv
        # nix
        nixgl.auto.nixGLDefault
        nix-output-monitor
        nixpkgs-fmt
        nil
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
    # systemd.user.tmpfiles.rules = [ "L+  %h/.nix-defexpr/nixos  -  -  -  -  ${nixpkgs}" ];
    targets.genericLinux.enable = true;
  };
}
