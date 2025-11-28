{ config, lib, pkgs, stateVersion, username, isOtherOS, inputs, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) optional mkIf;
  isNixos = builtins.hasAttr "system" config; # only present on NixOS systems
  checkVer = if isNixos then false else true;
in
{
  imports = [
    ../modules/home-manager

    # Modules exported from other flakes:
    inputs.nur.modules.homeManager.default
    inputs.catppuccin.homeModules.catppuccin
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.hmModules.nix-index
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.chaotic.homeManagerModules.default
    inputs.nur.hmModules.nur
  ]
  ++ optional (builtins.pathExists (./. + "/hosts")) ./hosts
  ++ optional (builtins.pathExists (./. + "/users")) ./users
  ;

  config = {
    home = {
      inherit stateVersion;
      inherit username;
      homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
      packages = with pkgs; [
        fd # Modern Unix `find`
        netdiscover # Modern Unix `arp`
        whereis-nix # nix store path
      ] ++ optionals (isOtherOS) [
        pciutils # Terminal PCI info
        duf # Modern Unix `df`
        usbutils # Terminal USB info
      ] ++ optionals (checkVer) [
        hm-build
        hm-switch
        hm-chsummary
      ];
    };
    programs = {
      nix-index.enable = true;
      tools.ssh.enable = true;
      home-manager.enable = checkVer;
      system.services.ssh.enable = true;
    };
  };
}
