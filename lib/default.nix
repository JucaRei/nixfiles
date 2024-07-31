{ inputs, outputs, stateVersion, lib, pkgs, config, ... }:
let
  helpers = import ./helpers.nix { inherit lib inputs outputs stateVersion config pkgs; };

  # wrapProgram = pkgs.callPackage ./wrap-program.nix { inherit lib pkgs; };

in
{
  inherit (helpers) mkHome mkHost systems;
}
