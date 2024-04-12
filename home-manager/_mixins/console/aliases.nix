{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.aliases;
in
{
  options.services.aliases = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      ### Nix ###
      # rebuild-home = "home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles";
      rebuild-home = "home-manager switch -b backup --impure --flake $HOME/.dotfiles/nixfiles";
      rebuild-lock = "pushd $HOME/.dotfiles/nixfiles && nix flake lock --recreate-lock-file && popd";
      sxorg = "export DISPLAY=:0.0";
      # rebuild-iso-console = "pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && popd";
      # rebuild-iso-desktop = "pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && popd";
      ping = "gping";
      nix-hash-sha256 = "nix-hash --flat --base32 --type sha256";
      # search = "nix search nixpkgs";
      mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
      mkdir = "mkdir -pv";
      cat = "${pkgs.bat}/bin/bat --paging=never";
      # diff = "${pkgs.diffr}/bin/diffr";
      # glow = "glow --pager";
      # ip = "${pkgs.iproute2}/bin/ip --color --brief";
      ip = "${pkgs.iproute2}/bin/ip --color --brief";

      less = "${pkgs.bat}/bin/bat --paging=always";
      more = "${pkgs.bat}/bin/bat --paging=always";
      top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
      wget = "${pkgs.wget2}/bin/wget2";
      # jq = "${pkgs.jiq}/bin/jiq";
      du = "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
      # cp = "${pkgs.unstable.advcpmv}/bin/advcp -rvi";
      # mv = "${pkgs.unstable.advcpmv}/bin/advmv -vi";
      cp = "${pkgs.unstable.advcpmv}/bin/advcp -R --progress-bar";
      mv = "${pkgs.unstable.advcpmv}/bin/advmv --progress-bar";
      audio = "${pkgs.inxi}/bin/inxi -A";
      battery = "${pkgs.inxi}/bin/inxi -B -xxx";
      bluetooth = "${pkgs.inxi}/bin/inxi -E";
      graphics = "${pkgs.inxi}/bin/inxi -G";
      macros = "cpp -dM /dev/null";
      pci = "sudo ${pkgs.inxi}/bin/inxi --slots";
      process = "${pkgs.inxi}/bin/inxi --processes";
      partitions = "${pkgs.inxi}/bin/inxi -P";
      repos = "${pkgs.inxi}/bin/inxi -r";
      sockets = "${pkgs.iproute2}/bin/ss -lp";
      system = "${pkgs.inxi}/bin/inxi -Fazy";
      usb = "${pkgs.inxi}/bin/inxi -J";
      wifi = "${pkgs.inxi}/bin/inxi -n";
    };
  };
}
