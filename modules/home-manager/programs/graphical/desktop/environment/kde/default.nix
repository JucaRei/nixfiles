{ config, pkgs, lib, ... }:

{
  home = {
    sessionVariables = {
      # XDG_CURRENT_DESKTOP = "KDE";
      # XDG_SESSION_DESKTOP = "KDE";
    };
    packages = with pkgs; [
      neofetch
    ];

    extraProfileCommands = ''
      kbuildsycoca5 --noincremental
    '';

    # https://github.com/nix-community/home-manager/issues/4996
    activation.updateKdeIconCache = lib.hm.dag.entryAfter [ "installPackages" ] ''
      run /usr/bin/kbuildsycoca5 --noincremental
    '';
  };
}
