{ lib, ... }:
{
  options.system.programs.multimedia = lib.mkOption {
    type = lib.types.submodule { };
    description = "Multimedia programs configuration";
  };

  imports = [
    ./mpv
    ./rhythmbox
  ];
}
