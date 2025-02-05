{ pkgs
, config
, lib
, modulesPath
, inputs
, namespace
, ...
}:
with lib;
with lib.${namespace};
{
  imports = with inputs.nixos-hardware.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    raspberry-pi-4
  ];

  # nixpkgs.config.allowUnsupportedSystem = true;
  # nixpkgs.crossSystem.system = "aarch64-linux";

  excalibur = {
    archetypes = {
      server = enabled;
    };

    system = {
      boot = {
        # Raspberry Pi requires a specific bootloader.
        enable = mkForce false;
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
