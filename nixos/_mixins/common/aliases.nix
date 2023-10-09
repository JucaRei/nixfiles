_: {
  environment.shellAliases = {
    ports = "sudo lsof -Pni"; # ports | fzf

    # fs
    r = "rsync -ra --info=progress2";
    # tree = "exa --tree";
    u = "aunpack"; # one tool to unpack them all
    fd = "fd --hidden --exclude .git";
    search = "nix search nixpkgs";

    ### NIX
    inspect-store = "nix path-info -rSh /run/current-system | sort -k2h ";
    wipe-user-packages = "nix-env -e '*'";

    tor = "nix-shell -p tor-browser-bundle-bin --run tor-browser";

    ### vnc
    # grab-display = "set DISPLAY ':0.0'";
    # vnc-server = "x11vnc -repeat -forever -noxrecord -noxdamage -rfbport 5900";
    # vnc = "vncviewer −FullscreenSystemKeys -MenuKey F12";
  };
}
