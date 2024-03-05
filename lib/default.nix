# { inputs, outputs, stateVersion, nixgl, pkgs, ... }:
{ inputs, outputs, stateVersion, lib, ... }:
let
  helpers =
    import ./helpers.nix { inherit inputs outputs stateVersion; };
  # // import ./attrsets.nix {inherit lib;};
  # nixGL = import ./nixGL.nix { inherit pkgs; };
in
{
  inherit (helpers) mkHome mkHost systems;
  # inherit

  # inherit (nixGL) self;
}
