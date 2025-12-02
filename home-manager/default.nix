{ config, lib, pkgs, stateVersion, username, isOtherOS, inputs, hostname, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) optionals mkIf;
in
{
  imports = [
    ../modules/home-manager
    ./users

    # Modules exported from other flakes:
    inputs.catppuccin.homeModules.catppuccin
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.homeModules.nix-index
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.chaotic.homeManagerModules.default
    inputs.nur.modules.homeManager.default
  ]
  ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}")) ./hosts/${hostname};

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
