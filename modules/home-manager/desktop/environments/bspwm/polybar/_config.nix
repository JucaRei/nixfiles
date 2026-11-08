{
  lib,
  cfg,
  colors,
  polybarModules,
}:
let
  pillsContext = import ./_config-pills-theme.nix { inherit lib cfg colors; };
  pillModuleOverrides = import ./_config-pills-modules.nix {
    inherit lib colors pillsContext;
  };
  bars = import ./_config-bars.nix {
    inherit cfg colors pillsContext;
  };
in
(lib.recursiveUpdate polybarModules pillModuleOverrides)
// {
  "colors" = colors;
}
// bars
