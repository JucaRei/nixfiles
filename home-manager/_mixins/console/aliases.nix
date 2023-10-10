_: {
  home.shellAliases = {
    ### Nix ###
    rebuild-home = "home-manager switch -b backup --flake $HOME/Zero/nixfiles";
    rebuild-lock = "pushd $HOME/Zero/nixfiles && nix flake lock --recreate-lock-file && popd";
    nix-clean = "nix-collect-garbage -d";
    # rebuild-iso-console = "pushd $HOME/Zero/nixfiles && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && popd";
    # rebuild-iso-desktop = "pushd $HOME/Zero/nixfiles && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && popd";
    nix-hash-sha256 = "nix-hash --flat --base32 --type sha256";
    search = "nix search nixpkgs";
    mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
    mkdir = "mkdir -pv";
    cat = "bat --paging=never";
    diff = "diffr";
    # glow = "glow --pager";
    ip = "ip --color --brief";
    less = "bat --paging=always";
    more = "bat --paging=always";
    top = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
    # tree = "exa --tree";
    wget = "wget2";
    jq = "jiq";
    gitpfolders = "for i in */.git; do ( echo $i; cd $i/..; git pull; ); done";
    du = "ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
    #htop = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
    # ls = "eza -Slhg";
    # lsa = "eza -Slhga";
    # ll = "eza -l";
    # la = "eza -a";
    # lt = "eza --tree";
    # lla = "eza -la";
  };
}
