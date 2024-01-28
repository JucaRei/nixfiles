{ inputs, outputs, stateVersion, nixgl, ... }:
let
  helpers = import ./helpers.nix { inherit inputs outputs nixgl stateVersion; };
in {
  inherit (helpers) mkHome;
  inherit (helpers) mkHost;
  inherit (helpers) systems;
}
