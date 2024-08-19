{ config, inputs, lib, isWorkstation, modulesPath, pkgs, nixpkgs, platform, ... }:
with lib;
{
  imports = [
    # ../../system
    inputs.auto-cpufreq.nixosModules.default
    inputs.catppuccin.nixosModules.catppuccin
    #inputs.determinate.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-snapd.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    (modulesPath + "/installer/scan/not-detected.nix")
  ] ++ lib.optional isWorkstation ./gui/desktop;

  # Only install the docs I use
  documentation = {
    enable = true;
    nixos.enable = false;
    man.enable = true;
    info.enable = false;
    doc.enable = false;
  };

  nixpkgs = {

    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
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

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      # allowUnsupportedSystem = true;
      # joypixels.acceptLicense = true; # Accept the joypixels license
      permittedInsecurePackages = [
        "python3.11-youtube-dl-2021.12.17"
      ];
      # allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
    };

    hostPlatform = lib.mkDefault "${platform}";
  };

  nix = {
    daemonIOSchedClass = "idle"; # Reduce disk usage # give nix-daemon the lowest priority
    daemonCPUSchedPolicy = "idle"; # Set CPU scheduling policy for daemon processes to idle # Leave nix builds as a background task
    daemonIOSchedPriority = 7; # Set I/O scheduling priority for daemon processes to 7
    optimise = {
      automatic = true;
      dates = [ "00:00" ];
    };
    settings = {
      # Manual optimise storage: nix-store --optimise
      # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes" # enable flakes
        "repl-flake" # repl to inspect a flake
        "recursive-nix" # let nix invoke itself
        "ca-derivations" # content addressed nix
        "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
        "cgroups" # allow nix to execute builds inside cgroups
      ];

      sandbox = "relaxed";
      allowed-users = [ "root" "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
      builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.

      ## Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      keep-going = true; # keep building even on some failure
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

      # do garbage collection weekly to keep disk usage low
      gc = {
        automatic = lib.mkDefault true;
        dates = lib.mkDefault "weekly";
        options = lib.mkDefault "--delete-older-than 7d";
        randomizedDelaySec = "14m";
      };

      # https://github.com/NixOS/nix/issues/9574
      nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
    };

    extraOptions = ''
      log-lines = 15
      # Free up to 4GiB whenever there is less than 2GiB left.
      min-free = ${toString (2048 * 1024 * 1024)}
      max-free = ${toString (4096 * 1024 * 1024)}
      connect-timeout = 5
    '';

    channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

    # auto upgrade nix to the unstable version
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/tools/package-management/nix/default.nix#L284
    package = pkgs.nixVersions.latest;

    # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
    registry.nixpkgs.flake = nixpkgs;

    # make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
    # discard all the default paths, and only use the one from this flake.
    nixPath = lib.mkForce [ "/etc/nix/inputs" ];
  };

  environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
}
