{ pkgs, ... }:
let
  build-host = import { inherit pkgs; };
in

{
  environment.systemPackages = builtins. with pkgs;[ ];
}
