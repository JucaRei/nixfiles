# default recipe to display help information
help:
  @just --list

alias u:= update

# update flake inputs (by default update dotfiles repo input)
update INPUT='$HOME/.dotfiles/nixfiles':
    nix flake update {{INPUT}}

update-all:
    nix flake update
