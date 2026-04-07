{ config, lib, pkgs, useNixGL ? false, osConfig ? null, ... }:
let
  inherit (lib) mkIf;

  isNixOS = osConfig != null;
in
{
  imports = [
    ./bspwm.nix
    ./sxhkd.nix
    ./polybar.nix
    ./packages.nix
  ];

  config = mkIf config.desktop.bspwm.enable {
    home = {
      sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.local/share/applications"
      ];
    };

    xdg = {
      mimeApps.enable = true;
      systemDirs = {
        data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];
        config = [ "/etc/xdg" ];
      };
    };

    # Enable generic Linux target for non-NixOS
    targets.genericLinux.enable = mkIf (!isNixOS) true;
  };
}
