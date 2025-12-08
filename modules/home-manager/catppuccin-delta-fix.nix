# This module disables the catppuccin delta configuration
# to work around the issue that home-manager 25.05 doesn't have programs.delta
{ config, lib, ... }:

{
  config = {
    catppuccin.delta.enable = lib.mkForce false;
  };
}
