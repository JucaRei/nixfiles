_: {
  home.shellAliases = {
    ### Nix ###
    # rebuild-home = "home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles";
    rebuild-home = "systemd-run --no-ask-password --uid=1000 --user --scope -p MemoryLimit=4000M -p CPUQuota=60% home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles | cachix push juca-nixfiles";
    rebuild-lock = "pushd $HOME/.dotfiles/nixfiles && nix flake lock --recreate-lock-file | cachix push juca-nixfiles && popd";
    nix-clean = "nix-collect-garbage -d";
    # nixos-rebuild = "systemd-run --no-ask-password --uid=0 --system --scope -p MemoryLimit=16000M -p CPUQuota=60% nixos-rebuild";
    # home-manager = "systemd-run --no-ask-password --uid=1000 --user --scope -p MemoryLimit=16000M -p CPUQuota=60% home-manager";
    # rebuild-iso-console = "pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && popd";
    # rebuild-iso-desktop = "pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && popd";
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
