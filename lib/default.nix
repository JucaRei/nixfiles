# { inputs, outputs, stateVersion, nixgl, pkgs, ... }:
{
  inputs,
  outputs,
  stateVersion,
  ...
}: let
  helpers = import ./helpers.nix {inherit inputs outputs stateVersion;};
  # nixGL = import ./nixGL.nix { inherit pkgs; };
in {
  inherit (helpers) mkHome mkHost systems;
  # inherit

  # inherit (nixGL) self;
}
