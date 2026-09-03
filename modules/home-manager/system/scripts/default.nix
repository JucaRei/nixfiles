{ pkgs, ... }:
let
  hm-build = import ./hm-build.nix { inherit pkgs; };
  hm-switch = import ./hm-switch.nix { inherit pkgs; };
  switch-home = pkgs.writeScriptBin "switch-home" ''
    #!${pkgs.stdenv.shell}
    exec ${hm-switch}/bin/hm-switch "$@"
  '';
  hm-chsummary = import ./hm-chsummary.nix { inherit pkgs; };
in
{
  home.packages = [
    hm-build
    hm-switch
    switch-home
    hm-chsummary
  ];
}
