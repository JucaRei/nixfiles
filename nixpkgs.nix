# Standalone nixpkgs loader for legacy nix-shell invocations.
# Evaluates using the exact locked nixpkgs commit from flake.lock.
let
  lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
in
import (fetchTarball {
  name = "nixpkgs-${lock.rev}";
  url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
  sha256 = lock.narHash;
})
