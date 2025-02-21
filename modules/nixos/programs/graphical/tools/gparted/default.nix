{ lib, config, namespace, ... }: {
  imports = [ (lib.snowfall.fs.get-file "modules/home/programs/graphical/tools/gparted/default.nix") ];
}
