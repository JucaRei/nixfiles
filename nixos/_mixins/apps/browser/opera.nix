{ pkgs, params, lib, ... }:

{
  environment.systemPackages = with pkgs.unstable; [ opera ];
}
