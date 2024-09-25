{ config, lib, username, platform, isInstall, outputs, inputs, pkgs, isISO, isWorkstation, hostname, ... }:
let
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf mkDefault;
  users = [
    "root"
    # "@wheel"
    # "nix-builder"
    "${username}"
  ];
in
{
  imports = [
    ./core
    ./users
  ];

  config = {
    ######################
    ### Custom Modules ###
    ######################
    core.boot = {
      enable = isInstall;
      # boottype = "efi";
      # bootmanager = "systemd-boot";
      # isDualBoot = false;
      # secureBoot = false;
      silentBoot = isWorkstation;
      plymouth = isWorkstation;
    };
    ####################
    ### Nix Settings ###
    ####################
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
        gc = {
          automatic = true;
          dates = "20:00"; # Schedule the task to run weekly / daily and 24hr time
          options = "--delete-older-than 7d"; # Specify options for the task: delete files older than 7days
          randomizedDelaySec = "14m";
          persistent = true;
        };
        # Disable channels
        channel.enable = false;
        # Make flake registry and nix path match flake inputs
        registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
        nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
        optimise = {
          automatic = isLinux;
          dates = [ "14:00" ];
        };
        package = mkIf isInstall pkgs.unstable.nix;
        settings = {
          sandbox = "relaxed"; # true
          nix-path = config.nix.nixPath;
          # Disable global registry
          flake-registry = "";
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
            # "repl-flake" # repl to inspect a flake
            # "recursive-nix" # let nix invoke itself
            # "ca-derivations" # content addressed nix
            # "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
            # "cgroups" # allow nix to execute builds inside cgroups
          ];
          # auto-allocate-uids = true;
          # Opinionated: disable global registry
          # flake-registry = "";
          # Workaround for https://github.com/NixOS/nix/issues/9574
          # allowed-users = users;
          trusted-users = users;
          builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.
          ### Avoid unwanted garbage collection when using nix-direnv
          keep-outputs = true;
          keep-derivations = true;
          keep-going = true;
          warn-dirty = false;
          tarball-ttl = 300; # Set the time-to-live (in seconds) for cached tarballs to 300 seconds (5 minutes)
          # use-cgroups = true; # execute builds inside cgroups
          system-features = [
            ## Allows building v3/v4 packages
            # "gccarch-x86-64-v3"
            # "gccarch-x86-64-v4"
            # "kvm"
            # "recursive-nix"
            # "big-parallel"
            # "nixos-test"
          ];
        };
        extraOptions = ''
          log-lines = 15
          # Free up to 4GiB whenever there is less than 2GiB left.
          min-free = ${toString (2048 * 1024 * 1024)}
          max-free = ${toString (4096 * 1024 * 1024)} # 4GiB
          connect-timeout = 10
        '';
      };
    ################
    ### Nixpkgs ####
    ################
    nixpkgs = {
      hostPlatform = mkDefault "${platform}";
      overlays = [
        # Add overlays your own flake exports (from overlays and pkgs dir):
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        outputs.overlays.legacy-packages
        # Add overlays exported from other flakes:
        # workaround for: https://github.com/NixOS/nixpkgs/issues/154163
        (_: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
        ## Testing
        (self: super: {
          vaapiIntel = super.vaapiIntel.override { enableHybridCodec = true; };
        })
      ];
      config = {
        # allowBroken = true;
        allowUnfree = true; # Disable if you don't want unfree packages
        joypixels.acceptLicense = true; # Accept the joypixels license
        # allowUnsupportedSystem = true;
        permittedInsecurePackages = [
          "python3.11-youtube-dl-2021.12.17"
        ];
        allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
      };
    };
    system = {
      activationScripts.report-changes = ''
        PATH=$PATH:${lib.makeBinPath [pkgs.nvd pkgs.nix]}
        nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
        mkdir -p /var/log/activations
        _nvddate=$(date +'%Y%m%d%H%M%S')
        nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2) > /var/log/activations/$_nvddate-$(ls -dv /nix/var/nix/profiles/system-*-link | tail -1 | cut -d '-' -f 2)-$(readlink $(ls -dv /nix/var/nix/profiles/system-*-link | tail -1) | cut -d - -f 4-).log
        if grep -q "No version or selection state changes" "/var/log/activations/$_nvddate-$(ls -dv /nix/var/nix/profiles/system-*-link | tail -1 | cut -d '-' -f 2)-$(readlink $(ls -dv /nix/var/nix/profiles/system-*-link | tail -1) | cut -d - -f 4-).log" ; then
          rm -rf "/var/log/activations/$_nvddate-$(ls -dv /nix/var/nix/profiles/system-*-link | tail -1 | cut -d '-' -f 2)-$(readlink $(ls -dv /nix/var/nix/profiles/system-*-link | tail -1) | cut -d - -f 4-).log"
        fi
      '';
    };
  };
}
