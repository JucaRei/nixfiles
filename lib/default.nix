{ inputs, outputs, stateVersion, lib, pkgs, ... }:
let
  callPackage = pkgs.lib.callPackageWith {
    inherit pkgs;
    inherit (pkgs) lib;
  };
  wrapProgram = callPackage ./wrap-program.nix { };

  helpers =
    import ./helpers.nix { inherit inputs outputs stateVersion; };

  # wrapProgram = pkgs.callPackage ./wrap-program.nix { inherit lib pkgs; };

in
{
  inherit (helpers) mkHome mkHost systems;
  inherit (wrapProgram) wrapProgram;
}
