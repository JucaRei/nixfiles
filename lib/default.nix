{ inputs
, outputs
, stateVersion
, pkgs
, config
, lib
, flakepath
, ...
}:
let
  helpers = import ./helpers.nix { inherit inputs outputs stateVersion lib pkgs config flakepath; };
in
{
  inherit (helpers) mkDarwin makeHome makeSystem systems;
}
