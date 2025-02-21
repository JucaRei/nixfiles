{ lib, ... }: {
  imports = [ (lib.snowfall.fs.get-file "modules/home/programs/graphical/social/element/default.nix") ];
}
