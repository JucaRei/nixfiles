{ inputs, outputs, lib, config, pkgs, hostname, platform, isInstall, username, ... }:
let
  inherit (lib) optional mkDefault mkOptionDefault;
in
{
  imports = [
    (./. + "/hosts/${hostname}/default.nix")
    ./users
    ../modules/nixos
  ] ++ (with inputs; [ ] ++ optional (lib.hasAttr "nixosModules" inputs.nixpkgs) inputs.nixpkgs.nixosModules.default);

  # This is the main configuration for your NixOS system.
  config = {
    nixpkgs = {
      overlays = [
        outputs.overlays.localPackages
        outputs.overlays.modifiedPackages
        outputs.overlays.unstablePackages
        outputs.overlays.oldstablePackages
        # Add more overlays here as needed

        (_: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];

      # Configure your nixpkgs instance
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
        # permittedInsecurePackages = [  ];
        # allowInsecure = true
      };
      hostPlatform = mkDefault "${platform}";
    };

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
          # "ca-derivations" # content addressed nix
          # "repl-flake" # repl to inspect a flake
          # "recursive-nix" # let nix invoke itself
          # "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
          # "configurable-impure-env" # allow impure environments
          # "git-hashing" # allow store objects which are hashed via Git's hashing algorithm
          # "verified-fetches" # enable verification of git commit signatures for fetchGit
          # "cgroups" # allow nix to execute builds inside cgroups
        ];
        system-features = [
          # "gccarch-x86-64-v3" # Allows building v3 packages
          # "gccarch-x86-64-v4" # Allows building v4 packages
          # "kvm"
          # "recursive-nix"
          # "big-parallel"
          # "nixos-test"
        ];
        ### Avoid unwanted garbage collection when using nix-direnv
        # keep-outputs = true;
        keep-derivations = true;
        keep-going = false;
        warn-dirty = false;
        tarball-ttl = 300; # Set the time-to-live (in seconds) for cached tarballs to 300 seconds (5 minutes)
        flake-registry = ""; # Opinionated: disable global registry
        nix-path = mkOptionDefault config.nix.nixPath; # Workaround for https://github.com/NixOS/nix/issues/9574
        trusted-users = [ "root" "${username}" ];
      };
      extraOptions = ''
        log-lines = 20
        # Free up to 4GiB whenever there is less than 2GiB left.
        min-free = ${toString (2048 * 1024 * 1024)}
        max-free = ${toString (4096 * 1024 * 1024)} # 4GiB
        connect-timeout = 8
      '';

      channel.enable = false; # Opinionated: disable channels

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

    # FIXME: Add the rest of your current configuration

    # TODO: Set your hostname
    networking.hostName = "your-hostname";

    # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
    users.users = {
      # FIXME: Replace with your username
      your-username = {
        # TODO: You can set an initial password for your user.
        # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
        # Be sure to change it (using passwd) after rebooting!
        initialPassword = "correcthorsebatterystaple";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
        ];
        # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
        extraGroups = [ "wheel" ];
      };
    };

    # This setups a SSH server. Very important if you're setting up a headless system.
    # Feel free to remove if you don't need it.
    services.openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system = {
      nixos.label = lib.mkIf isInstall "nixsystem";
      stateVersion = "23.05";
    };
  };
}
