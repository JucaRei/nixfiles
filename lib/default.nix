{ inputs, outputs, stateVersion, pkgs, ... }:
let
  helpers = import ./helper.nix { inherit inputs outputs stateVersion pkgs; };
in
{
  inherit (helpers)
    # mkDarwin
    makeHomeManager
    makeNixOS
    forAllSystems
    ;
}
