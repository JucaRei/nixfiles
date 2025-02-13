{ outputs, lib, ... }:
{
  ### Shared modules ###

  nix = {
    settings = {
      experimental-features = [
        "flakes" # flakes
        "nix-command" # experimental nix commands
      ];
      trusted-users = [ "root" ];
      warn-dirty = false;
      allow-dirty = true;
    };
  };

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.oldstable-packages

      # Add overlays exported from other flakes:
    ];

    config = {
      allowUnfree = true;
    };
  };
}
