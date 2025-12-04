{ inputs, lib, config, pkgs, modulesPath, hostname, username, stateVersion, platform, ... }:
let
  inherit (lib) optional;
in
{
  # You can import other NixOS modules here
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs = {
    hostPlatform = "${platform}";
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.localPackages
      inputs.self.overlays.modifiedPackages
      inputs.self.overlays.unstable-packages
      inputs.self.overlays.oldstable-packages

    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs; in {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      nix-path = config.nix.nixPath;
    };
    channel.enable = false;

    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # FIXME: Add the rest of your current configuration

  # TODO: Set your hostname
  networking.hostName = "${hostname}";

  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "yes";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = stateVersion;
}
