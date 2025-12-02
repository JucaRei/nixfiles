{ config, lib, pkgs, stateVersion, username, isOtherOS, inputs, hostname, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) optional optionals mkIf;
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
  ++ optional (builtins.pathExists (./. + "/hosts/${hostname}")) ./hosts/${hostname}
  ++ optional (builtins.pathExists (./. + "/users")) ./users;

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
      ];
    };
    programs = {
      nix-index.enable = true;
      tools.ssh.enable = true;
      system.services.ssh.enable = true;
    };
  };
}
