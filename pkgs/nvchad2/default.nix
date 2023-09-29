{ lib, stdenv, fetchFromGitHub, pkgs, ... }:

let
  pname = "nvchad";
  version = "2.0";

  src = pkgs.fetchFromGitHub {
    owner = "nvchad";
    repo = "nvchad";
    rev = "v${version}";
    sha256 = "1pfpyvgqw8ip153sj3nsv8a0hd267iqm7fizb526w2xg0b221ib7";
  };

  launcher = pkgs.writeScript "nvchad" ''
    export PATH="${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.neovim pkgs.ripgrep pkgs.fd pkgs.ueberzug ]}"
    export XDG_CONFIG_HOME=$(mktemp -d)

    # FIXME: Use the real XDG_CONFIG_HOME or fallback to $HOME/.config
    mkdir -p $HOME/.config/nvchad

    # Set up a disposable XDG_CONFIG_HOME
    mkdir $XDG_CONFIG_HOME/nvim
    ln -s ${src}/LICENSE $XDG_CONFIG_HOME/nvim/LICENSE
    ln -s ${src}/README.md $XDG_CONFIG_HOME/nvim/README.md
    ln -s ${src}/init.lua $XDG_CONFIG_HOME/nvim/init.lua
    cp -r ${src}/lua $XDG_CONFIG_HOME/nvim/lua
    chmod u+w $XDG_CONFIG_HOME/nvim/lua
    ln -s $HOME/.config/nvchad $XDG_CONFIG_HOME/nvim/lua/custom

    # Copy the initial user configuration, if it doesn't already exist.
    cp -n ${src}/lua/chadrc.lua $HOME/.config/nvchad/

    exec nvim "$@"
  '';
in
pkgs.stdenv.mkDerivation {
  inherit src version pname;

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${launcher} $out/bin/nvchad
  '';
}
