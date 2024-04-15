{ inputs, outputs, stateVersion, lib, pkgs, ... }:
let
  helpers =
    import ./helpers.nix { inherit inputs outputs stateVersion; };

  # wrapProgram = pkgs.callPackage ./wrap-program.nix { inherit lib pkgs; };

in
{
  inherit (helpers) mkHome mkHost systems;
}
