{ config, lib, pkgs, username, hostname, stateVersion, osConfig ? null, inputs, ... }:
let
  inherit (lib) optional optionals;

  isNixOS = osConfig != null;
in
{
  imports = [ ../modules/home-manager ]
    ++ optional (builtins.pathExists ./users/${username}) ./users/${username}
    ++ optional (builtins.pathExists ./hosts/${hostname}) ./hosts/${hostname};

  disabledModules = [
    # Disable catppuccin delta module as it requires programs.delta which is not available in home-manager 25.05
    # "${inputs.catppuccin}/modules/home-manager/delta.nix"
  ];

  home = {
    packages = with pkgs; [
      fd # Modern Unix `find`
      netdiscover # Modern Unix `arp`
      whereis-nix # nix store path
    ] ++ optionals (!isNixOS) [
      pciutils # Terminal PCI info
      duf # Modern Unix `df`
      usbutils # Terminal USB info
    ];
  };
  programs = {
    nix-index.enable = true;
  };
}
