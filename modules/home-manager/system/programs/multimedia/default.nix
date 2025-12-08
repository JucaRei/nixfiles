{ lib, ... }:
{
  options.system.programs.multimedia = lib.mkOption {
    type = lib.types.submodule { };
    default = { };
    description = "Multimedia programs configuration";
  };

  imports = [
    ./mpv
    ./rhythmbox
  ];
}
