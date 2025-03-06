{ config, lib, pkgs, username, stateVersion, isLima, ... }:
let
  inherit (lib) mkOptionDefault mkForce;
in
{
  imports = [
    ../../programs
    ../../system
  ];

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

    terminal = {
      shell = {
        bash.enable = true;
      };
    };
  };

  system = {
    user = {
      # Nicely reload system units when changing configs
      startServices = "sd-switch";
    };
  };
}
