{ lib
, config
, hostname
, pkgs
, ...
}: {
  home.shellAliases = {
    ### Nix ###
    # rebuild-home = "home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles";
    rebuild-home =
      if (hostname != "zion" || "vm")
      then "systemd-run --no-ask-password --uid=1000 --user --scope -p MemoryLimit=4000M -p CPUQuota=60% home-manager switch -b backup --impure --flake $HOME/.dotfiles/nixfiles"
      else "home-manager switch -b backup --impure --flake $HOME/.dotfiles/nixfiles";
    # rebuild-home =
    # "home-manager switch -b backup --impure --flake $HOME/.dotfiles/nixfiles";
    rebuild-lock = "pushd $HOME/.dotfiles/nixfiles && nix flake lock --recreate-lock-file && popd";
    nix-clean = "nix-collect-garbage -d";
    sxorg = "export DISPLAY=:0.0";
    # nixos-rebuild = "systemd-run --no-ask-password --uid=0 --system --scope -p MemoryLimit=16000M -p CPUQuota=60% nixos-rebuild";
    # home-manager = "systemd-run --no-ask-password --uid=1000 --user --scope -p MemoryLimit=16000M -p CPUQuota=60% home-manager";
    # rebuild-iso-console = "pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && popd";
    # rebuild-iso-desktop = "pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && popd";
    nix-hash-sha256 = "nix-hash --flat --base32 --type sha256";
    search = "nix search nixpkgs";
    mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
    mkdir = "mkdir -pv";
    cat = "${pkgs.bat}/bin/bat --paging=never";
    diff = "${pkgs.diffr}/bin/diffr";
    # glow = "glow --pager";
    ip = "${pkgs.iproute2}/bin/ip --color --brief";
    less = "${pkgs.bat}/bin/bat --paging=always";
    more = "${pkgs.bat}/bin/bat --paging=always";
    top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
    wget = "${pkgs.wget2}/bin/wget2";
    jq = "${pkgs.jiq}/bin/jiq";
    du = "${pkgs.ncdu_1}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
    #htop = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
    # ls = "eza -Slhg";
    # lsa = "eza -Slhga";
    # ll = "eza -l";
    # la = "eza -a";
    # lt = "eza --tree";
    # lla = "eza -la";
  };
}
