{ inputs
, outputs
, stateVersion
, pkgs
, ...
}:
let
  helpers = import ./helpers.nix { inherit inputs outputs stateVersion pkgs; };
in
{
  inherit (helpers) mkDarwin makeHome makeSystem forAllSystems;
}
