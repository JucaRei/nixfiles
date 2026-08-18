{ config, inputs, outputs, pkgs, platform, lib, isInstall, stateVersion, username, isWorkstation, ... }:
let
  inherit (lib) mkDefault mkOptionDefault mkIf;
in
{
  imports = [
    ./hardware
    ./system
  ] ++ lib.optional isWorkstation ./desktop;


  config = {
    nix = let flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs; in {
      # give nix-daemon the lowest priority
      daemonIOSchedClass = "idle";
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedPriority = 7;
      settings = {
        # accept-flake-config = true;
        # extra-sandbox-paths = [ "/bin/sh=${pkgs.bash}/bin/sh" ];
        experimental-features = [
          "nix-command" # Enable the new 'nix' command
          "flakes" # Enable flakes
          "pipe-operators" # Enable pipe operators
          "ca-derivations" # content addressed nix
          "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
          # "repl-flake" # repl to inspect a flake
          # "recursive-nix" # let nix invoke itself
          # "configurable-impure-env" # allow impure environments
          # "git-hashing" # allow store objects which are hashed via Git's hashing algorithm
          # "verified-fetches" # enable verification of git commit signatures for fetchGit
          # "cgroups" # allow nix to execute builds inside cgroups
        ];
        extra-experimental-features = "parallel-eval";
        lazy-trees = true;
        eval-cores = 0; # Enable parallel evaluation across all cores
        system-features = [
          # "gccarch-x86-64-v3" # Allows building v3 packages
          # "gccarch-x86-64-v4" # Allows building v4 packages
          "kvm" # Virtualization support
          "big-parallel" # High-parallelism builds
          "benchmark" # Performance-sensitive builds
          "nixos-test" # NixOS testing
          "uid-range" # For auto-allocate-uids
          # "recursive-nix"
        ];
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" # nix-community cachix
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" # NixOS cache
          # Add more if needed for other caches
        ];
        ### Avoid unwanted garbage collection when using nix-direnv
        keep-outputs = true;
        keep-derivations = true;
        keep-going = false;
        warn-dirty = false;
        tarball-ttl = 300; # Set the time-to-live (in seconds) for cached tarballs to 300 seconds (5 minutes)
        flake-registry = ""; # Opinionated: disable global registry
        nix-path = mkOptionDefault config.nix.nixPath; # Workaround for https://github.com/NixOS/nix/issues/9574
        trusted-users = [ "root" "${username}" ];
        # Auto-optimize store to reduce disk usage
        auto-optimise-store = true;
        # Build parallelism
        max-jobs = mkDefault "auto";
        # Free up space automatically
        min-free = 2048 * 1024 * 1024; # 2GiB
        max-free = 4096 * 1024 * 1024; # 4GiB
        log-lines = 25;
        connect-timeout = 10;
      };
      channel.enable = false; # Opinionated: disable channels
      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      # Configure your nixpkgs instance
      config = {
        allowUnfree = true;
        allowBroken = true;
        allowInsecure = true;
        nvidia.acceptLicense = true;
        permittedInsecurePackages = [
          "broadcom-sta-6.30.223.271-59-6.18"
          "broadcom-sta"
        ];
      };
      hostPlatform = mkDefault "${platform}";
    };

    system = {
      nixos.label = mkIf isInstall "NIXOS_SYSTEM";
      inherit stateVersion;

      activationScripts = {
        diff = {
          supportsDryActivation = true;
          text = ''
            BLUE=$(${pkgs.ncurses}/bin/tput setaf 4)
            CLEAR=$(${pkgs.ncurses}/bin/tput sgr0)
            if [[ -e /run/current-system ]]; then
              echo "$BLUE   $CLEAR System Diff Report $BLUE   $CLEAR"
              echo "#"
              mkdir -p /var/log/nix
              ${pkgs.nvd}/bin/nvd --color=always --nix-bin-dir=${config.nix.package}/bin diff $(${pkgs.coreutils}/bin/readlink "/run/current-system") "$systemConfig" | tee /var/log/nix/nix-changelog
              echo "#"
              echo "$BLUE                $CLEAR"
            fi
          '';
        };

        nixos-needsreboot = mkIf isInstall {
          supportsDryActivation = true;
          text = "${
            lib.getExe inputs.nixos-needsreboot.packages.${pkgs.stdenv.hostPlatform.system}.default
          } \"$systemConfig\" || true";
        };
      };
    };
  };
}
