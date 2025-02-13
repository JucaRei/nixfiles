{ pkgs, inputs, lib, ... }:
let
  isOtherOS = if builtins.isString (builtins.getEnv "__NIXOS_SET_ENVIRONMENT_DONE") then false else true;
in
{
  imports = with inputs; [
    # Modules exported from other flakes:
    nur.modules.homeManager.default
    catppuccin.homeManagerModules.catppuccin
    sops-nix.homeManagerModules.sops
    nix-index-database.hmModules.nix-index
    nix-flatpak.homeManagerModules.nix-flatpak
    chaotic.homeManagerModules.default
  ];

  home = {
    packages = with pkgs;[
      fd # Modern Unix `find`
      netdiscover # Modern Unix `arp`
    ] ++
    optional (isOtherOS) [
      pciutils # Terminal PCI info
      duf # Modern Unix `df`
      usbutils # Terminal USB info
    ];
  };

  programs = {
    nix-index.enable = true;
  };
}
