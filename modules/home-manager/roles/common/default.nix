{ config, lib, pkgs, username, stateVersion, isLima, ... }:
let
  inherit (lib) mkOptionDefault mkForce;
in
{
  catppuccin = {
    accent = "blue";
    flavor = "mocha";
  };

  programs = {
    home-manager = {
      enable = true;
    };
    nix-index = {
      enable = true;
    };
  };

  system = {
    user = {
      # Nicely reload system units when changing configs
      startServices = "sd-switch";
    };
  };
}
