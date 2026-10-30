{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  config = {
    system.programs.multimedia.mpv = {
      hybridGraphics = mkDefault false;
    };
  };
}
