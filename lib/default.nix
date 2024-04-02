{ inputs, outputs, stateVersion, lib, ... }:
let
  helpers =
    import ./helpers.nix { inherit inputs outputs stateVersion; };

  # wrapProgram = pkgs.callPackage ./wrap-program.nix { inherit lib pkgs; };

in
{
  inherit (helpers) mkHome mkHost systems;
  # inherit (wrapProgram) wrapProgram;
}
