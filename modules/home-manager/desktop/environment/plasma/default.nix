{ pkgs, lib, ... }: {
  desktop.backend = "wayland";
  home = {
    sessionVariables = { };
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
