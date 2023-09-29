_: {
  environment.shellAliases = {
    ports = "sudo lsof -Pni"; # ports | fzf

    # fs
    r = "rsync -ra --info=progress2";
    tree = "exa --tree";
    u = "aunpack"; # one tool to unpack them all
    fd = "fd --hidden --exclude .git";
    search = "nix search nixpkgs";
  };
}
