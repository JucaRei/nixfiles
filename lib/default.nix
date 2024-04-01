# { inputs, outputs, stateVersion, nixgl, pkgs, ... }:
{ inputs, outputs, stateVersion, lib, pkgs, ... }:
let
  helpers =
    import ./helpers.nix { inherit inputs outputs stateVersion; };

  wrapProgram = pkgs.callPackage ./wrap-program.nix { };
  # // import ./attrsets.nix {inherit lib;};
  # nixGL = import ./nixGL.nix { inherit pkgs; };
in
{
  inherit (helpers) mkHome mkHost systems;
  inherit (wrapProgram) wrapProgram;
  # inherit

  # inherit (nixGL) self;
}
