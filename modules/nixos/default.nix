# Reusable NixOS modules
# - https://wiki.nixos.org/wiki/NixOS_modules
{ pkgs, lib, config, inputs, username, platform, outputs, ... }:
let
  inherit (lib) mkDefault;
in
{
  imports = [ ../default.nix ];
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      # give nix-daemon the lowest priority
      daemonIOSchedClass = "idle"; # Reduce disk usage
      # Leave nix builds as a background task
      daemonCPUSchedPolicy = "idle"; # Set CPU scheduling policy for daemon processes to idle
      daemonIOSchedPriority = 7; # Set I/O scheduling priority for daemon processes to 7

      settings = {
        accept-flake-config = true;
        extra-sandbox-paths = [ "/bin/sh=${pkgs.bash}/bin/sh" ];
        experimental-features = [
          # "recursive-nix" # let nix invoke itself
          # "ca-derivations" # content addressed nix
          # "repl-flake" # repl to inspect a flake
          # "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
          # "cgroups" # allow nix to execute builds inside cgroups
          # "configurable-impure-env" # allow impure environments
          # "git-hashing" # allow store objects which are hashed via Git's hashing algorithm
          # "verified-fetches" # enable verification of git commit signatures for fetchGit
        ];
        auto-allocate-uids = true;
        use-cgroups = true; # execute builds inside cgroups
        # allowed-users = users;
        # builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.
        system-features = [
          ## Allows building v3/v4 packages
          # "gccarch-x86-64-v3"
          # "gccarch-x86-64-v4"
          # "kvm"
          # "recursive-nix"
          # "big-parallel"
          # "nixos-test"
        ];
        ### Avoid unwanted garbage collection when using nix-direnv
        keep-outputs = true;
        keep-derivations = true;
        keep-going = false;
        tarball-ttl = 300; # Set the time-to-live (in seconds) for cached tarballs to 300 seconds (5 minutes)
        # Disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        trusted-users = [ "${username}" ];
      };
      extraOptions = ''
        log-lines = 15
        # Free up to 4GiB whenever there is less than 2GiB left.
        min-free = ${toString (2048 * 1024 * 1024)}
        max-free = ${toString (4096 * 1024 * 1024)} # 4GiB
        connect-timeout = 10
      '';
      # Disable channels
      channel.enable = false;
      # Make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      # outputs.overlays.additions
      # outputs.overlays.modifications
      # Add overlays exported from other flakes:

      # Add overlays exported from other flakes:
      # workaround for: https://github.com/NixOS/nixpkgs/issues/154163
      (_: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    hostPlatform = mkDefault "${platform}";
    # Configure your nixpkgs instance
    config = {
      allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
      permittedInsecurePackages = [
        "tightvnc-1.3.10"
      ];
      allowInsecure = true;
    };
  };
}
