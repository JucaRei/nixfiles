{
  lib,
  pkgs,
  stateVersion,
  username,
  osConfig ? null,
  inputs,
  hostname,
  isWorkstation ? false,
  isVM ? false,
  desktop ? null,
  nixGLType ? null,
  ...
}:
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
  ]
  ++ lib.optional isWorkstation ../profiles/home/workstation.nix
  ++ lib.optional (!isWorkstation) ../profiles/home/minimal.nix
  ++ lib.optional isVM ../profiles/home/vm.nix
  ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}")) ./hosts/${hostname};

  config = {
    assertions = [
      {
        assertion = isNixOS || (builtins.hasAttr hostname (import ../hosts.nix).home);
        message = "hosts.nix: A máquina '${hostname}' não está registrada sob 'home = { ... }'. Registre-a em hosts.nix ou use './scripts/nx new-host ${hostname}'.";
      }
      {
        assertion =
          desktop == null
          || builtins.elem desktop [
            "bspwm"
            "dwm"
            "mangowm"
            "mango"
            "hyprland"
            "xfce4"
            "gnome"
            "mate"
            "pantheon"
            "sway"
            "i3"
          ];
        message = "hosts.nix: Ambiente gráfico '${toString desktop}' não suportado para o host '${hostname}'. Ambientes válidos: bspwm, dwm, mangowm, hyprland, xfce4, gnome, mate, pantheon, sway, i3 (ou null). Edite 'desktop = \"...\"' em hosts.nix.";
      }
      {
        assertion = builtins.elem nixGLType [
          null
          "auto"
          "intel"
          "mesa"
          "nvidia"
        ];
        message = "hosts.nix: nixGLType '${toString nixGLType}' inválido para o host '${hostname}'. Valores aceitos: \"intel\", \"mesa\", \"nvidia\", \"auto\" (ou null). Corrija a definição em hosts.nix.";
      }
    ];

    home = {
      inherit stateVersion;
      inherit username;
      homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
      packages =
        with pkgs;
        [
          fd # Modern Unix `find`
          netdiscover # Modern Unix `arp`
          whereis-nix # nix store path
        ]
        ++ optionals (!isNixOS) [
          pciutils # Terminal PCI info
          duf # Modern Unix `df`
          usbutils # Terminal USB info
        ];

      activation.cleanStaleBackups = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        find "$HOME/.config" "$HOME/.mozilla" -maxdepth 4 \( -name "*.hm.backup" -o -name "*.home-manager.backup" \) -exec rm -f {} + 2>/dev/null || true
      '';
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
