{ inputs
, outputs
, stateVersion
, pkgs
, config
, lib
, ...
}:
let
  helpers = import ./helpers.nix { inherit inputs outputs stateVersion lib pkgs config; };
in
{
  inherit (helpers) mkDarwin makeHome makeSystem systems;
}
