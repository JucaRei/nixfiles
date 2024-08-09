{ config, lib, username, platform, isInstall, outputs, inputs, pkgs, isISO, isWorkstation, ... }:
with lib;
let
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  variables = import ./hosts/${hostname}/variables.nix { inherit config username; }; # vars for better check
  inherit (pkgs.stdenv) isLinux;
in
{
  imports = [
    ./core
    # ./common.nix
  ];

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
        options = "--delete-older-than 10d"; # Specify options for the task: delete files older than 10 days
        randomizedDelaySec = "14m";
      };

      # distributedBuilds = true;
      ### This will add each flake input as a registry
      ### To make nix3 commands consistent with your flake

      registry = mapAttrs (_: value: { flake = value; }) inputs;
      # Opinionated: make flake registry and nix path match flake inputs

      ### Add nixpkgs input to NIX_PATH
      ### This lets nix2 commands still use <nixpkgs>
      nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];

      optimise = {
        automatic = isLinux;
        dates = [ "14:00" ];
      };
      package = mkIf (isInstall) pkgs.unstable.nix;
      settings = {
        # Always build inside sandboxed environments
        # sandbox = true;
        sandbox = "relaxed"; # true

        # extra-sandbox-paths = [ ];
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
          "repl-flake" # repl to inspect a flake
          "recursive-nix" # let nix invoke itself
          "ca-derivations" # content addressed nix
          "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
          "cgroups" # allow nix to execute builds inside cgroups
        ];
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;

        allowed-users = [ "root" "${username}" ];
        trusted-users = [ "root" "${username}" ];
        builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.
        ### Avoid unwanted garbage collection when using nix-direnv
        keep-outputs = true;
        keep-derivations = true;
        keep-going = true;
        warn-dirty = false;
        tarball-ttl = 300; # Set the time-to-live (in seconds) for cached tarballs to 300 seconds (5 minutes)
        use-cgroups = true; # execute builds inside cgroups
        system-features = [
          ## Allows building v3/v4 packages
          "gccarch-x86-64-v3"
          "gccarch-x86-64-v4"
          "kvm"
          "recursive-nix"
          "big-parallel"
          "nixos-test"
        ];
      };

      extraOptions =
        ''
          log-lines = 15
          # Free up to 4GiB whenever there is less than 2GiB left.
          min-free = ${toString (2048 * 1024 * 1024)}
          max-free = ${toString (4096 * 1024 * 1024)}
          connect-timeout = 10
        '';
      # Free up to 4GiB whenever there is less than 512MiB left.
      # min-free = ${toString (512 * 1024 * 1024)}
      # min-free = 1073741824 # 1GiB
      # max-free = 4294967296 # 4GiB
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
      outputs.overlays.previous-packages
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
        #   deadbeef = super.deadbeef.override { wavpackSupport = true; };
        #   deadbeef-with-plugins = super.deadbeef-with-plugins.override {
        #     plugins = with super.deadbeefPlugins; [ mpris2 statusnotifier ];
        #   };
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

      # allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
    };
  };
}
