{ pkgs, lib, params, ... }:
let
  ifDefault = lib.mkIf (params.browser == "brave");
in
{
  environment.systemPackages = with pkgs.unstable; [
    brave
  ];

}
