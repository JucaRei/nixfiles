{ inputs, lib, config, pkgs, modulesPath, hostname, username, stateVersion, platform, isWorkstation, ... }:
let
  inherit (lib) mkDefault mkIf optional;

  # Only enable zram swap if no swap devices are configured
  usezramSwap = builtins.length config.swapDevices == 0;

  systemModules = with inputs; [
    nur.modules.nixos.default
    disko.nixosModules.disko
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
    auto-cpufreq.nixosModules.default
    nix-flatpak.nixosModules.nix-flatpak
    chaotic.nixosModules.default
    lanzaboote.nixosModules.lanzaboote
  ];
in
{
  # You can import other NixOS modules here
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware
    ./services
  ] ++ optional isWorkstation ./desktop
  ++ systemModules;

  config = {
    nixpkgs = {
      hostPlatform = "${platform}";
      # You can add overlays here
      overlays = [
        # Add overlays your own flake exports (from overlays and pkgs dir):
        inputs.self.overlays.localPackages
        inputs.self.overlays.modifiedPackages
        inputs.self.overlays.unstable-packages
        inputs.self.overlays.oldstable-packages

        # Raspberry fix
        (_: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
      # Configure your nixpkgs instance
      config = {
        allowUnfree = true; # Disable if you don't want unfree packages
        allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
        # permittedInsecurePackages = [  ];
        # allowInsecure = true
      };
    };

    nix = let flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs; in {
      daemonIOSchedClass = "idle"; # give nix-daemon the lowest priority
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
        # extra-experimental-features = "parallel-eval";
        # lazy-trees = true;
        # eval-cores = 0; # Enable parallel evaluation across all cores
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
        trusted-users = [ "root" "${username}" ];
        # Auto-optimize store to reduce disk usage
        auto-optimise-store = true;
        # Build parallelism (set to "auto" for daemon to use all cores; use wrapper for dynamic half-cores during rebuilds)
        max-jobs = mkDefault "auto";
        # Free up space automatically
        min-free = 2048 * 1024 * 1024; # 2GiB
        max-free = 4096 * 1024 * 1024; # 4GiB
        ### Avoid unwanted garbage collection when using nix-direnv
        keep-outputs = true;
        keep-derivations = true;
        keep-going = false;
        warn-dirty = false;
        tarball-ttl = 300; # Set the time-to-live (in seconds) for cached tarballs to 300 seconds (5 minutes)
        flake-registry = "";
        nix-path = config.nix.nixPath; # Workaround for https://github.com/NixOS/nix/issues/9574
      };
      channel.enable = false;
      extraOptions = ''
        log-lines = 25
        connect-timeout = 10
      '';

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

    hardware = {
      cpu = mkDefault {
        enable = true;
        hardenKernel = false;
        improveTCP = false;
        enableKvm = false;
        cpuVendor = "other";
      };
    };

    systemd = {
      extraConfig = ''
        DefaultTimeoutStopSec=10s
        DefaultCPUAccounting=yes
        DefaultMemoryAccounting=yes
        DefaultIOAccounting=yes
      '';
      tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
      ];

      services = {
        "mglru" = mkIf (usezramSwap) {
          enable = true;
          wantedBy = [ "basic.target" ];
          script = ''${pkgs.uutils-coreutils-noprefix}/bin/echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms'';
          serviceConfig = {
            Type = "oneshot";
          };
          unitConfig = {
            ConditionPathExists = "/sys/kernel/mm/lru_gen/enabled";
            Description = "Configure Enable Multi-Gen LRU";
          };
        };
      };
    };

    system = {
      nixos.label = "_Nix-System_";

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = stateVersion;

      activationScripts = {
        diff = {
          supportsDryActivation = true;
          text = ''
            BLUE=$(${pkgs.ncurses}/bin/tput setaf 4)
            CLEAR=$(${pkgs.ncurses}/bin/tput sgr0)

            if [[ -e /run/current-system ]]; then
              echo "$BLUE   $CLEAR System Diff Report $BLUE   $CLEAR"
              echo "#"
              ${pkgs.nvd}/bin/nvd --color=always --nix-bin-dir=${config.nix.package}/bin diff $(${pkgs.coreutils}/bin/readlink "/run/current-system") "$systemConfig" | tee /var/log/nix/nix-changelog
              echo "#"
              echo "$BLUE                $CLEAR"
            fi
          '';
        };
      };
      switch = {
        # enable = true; # false; # Perl
        enableNg = true; # Rust-based re-implementation of the original Perl switch-to-configuration
      };
    };

    zramSwap = {
      algorithm = "zstd";
      enable = usezramSwap;
      memoryPercent = 100;
    };
  };
}
