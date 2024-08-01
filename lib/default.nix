{ inputs, outputs, stateVersion, lib, pkgs, config, ... }:
let
  helpers = import ./helpers.nix { inherit inputs outputs stateVersion lib pkgs config; };

  # wrapProgram = pkgs.callPackage ./wrap-program.nix { inherit lib pkgs; };

in
{
  inherit (helpers) makeHomeManager makeNixOS systems;
}
