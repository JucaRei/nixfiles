{ pkgs, ... }:

pkgs.writeShellScriptBin "random-wall" ''
  wall=$(find ~/Pictures/wallpapers -type f -name "*.png" -o -name "*.jpg"| shuf -n 1)

  swww img $wall &
  wal -i $wall &&  reload &
''
