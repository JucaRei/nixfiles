{ lib, ... }:
{
  options.system.programs.multimedia = lib.mkOption {
    type = lib.types.submodule {
      options = {
        mpv = lib.mkOption {
          type = lib.types.submodule {
            options = {
              enable = lib.mkEnableOption "mpv media player";
            };
          };
          default = { };
          description = "MPV player configuration";
        };
        rhythmbox = lib.mkOption {
          type = lib.types.submodule {
            options = {
              enable = lib.mkEnableOption "rhythmbox music player";
            };
          };
          default = { };
          description = "Rhythmbox music player configuration";
        };
      };
    };
    default = { };
    description = "Multimedia programs configuration";
  };

  imports = [
    ./mpv
    ./rhythmbox
  ];
}
