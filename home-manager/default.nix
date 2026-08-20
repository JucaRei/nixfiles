{ lib, pkgs, stateVersion, username, osConfig ? null, inputs, hostname, ... }:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (lib) optionals;
  isNixOS = osConfig != null;
in
{
  imports = [
    ../modules/home-manager
    ./users

    # External flake modules
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.homeModules.nix-index
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nur.modules.homeManager.default
  ]
  ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}")) ./hosts/${hostname};


  disabledModules = [
    # Disable catppuccin delta module as it requires programs.delta which is not available in home-manager 25.05
    "${inputs.catppuccin}/modules/home-manager/delta.nix"
  ];

  config = {
    home = {
      inherit stateVersion;
      inherit username;
      homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
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
      home-manager.enable = true;
    };
    system = {
      programs.tools.ssh.enable = true;
      services.ssh.enable = true;
    };
  };
}
