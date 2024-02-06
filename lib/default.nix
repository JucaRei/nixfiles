# { inputs, outputs, stateVersion, nixgl, pkgs, ... }:
{ inputs, outputs, stateVersion, nixgl, ... }:
let
  helpers = import ./helpers.nix { inherit inputs outputs nixgl stateVersion; };

  # nixGL = import ./nixGL.nix { inherit pkgs; };
in {
  inherit (helpers) mkHome mkHost systems;
  # inherit

  # inherit (nixGL) self;
}
