{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs
, stateVersion, username, hostid, ... }: {
  # Import host specific boot and hardware configurations.
  # Only include desktop components if one is supplied.
  # - https://nixos.wiki/wiki/Nix_Language:_Tips_%26_Tricks#Coercing_a_relative_path_with_interpolated_variables_to_an_absolute_path_.28for_imports.29
  imports = [
    # inputs.home-manager.nixosModules.home-manager
    inputs.vscode-server.nixosModules.default
    inputs.disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    (./. + "/hosts/${hostname}")
    ./_mixins/services/network/openssh.nix
    ./_mixins/services/tools/smartmon.nix
    ./_mixins/common
    ./users/root
    ./shared.nix
  ] ++ lib.optional (builtins.pathExists (./. + "/users/${username}"))
    ./users/${username} ++ lib.optional (desktop != null) ./_mixins/desktop
    ++ lib.optional (hostname != "rasp3" || "air")
    ./_mixins/services/tools/kmscon.nix;

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # workaround for: https://github.com/NixOS/nixpkgs/issues/154163
      (_: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })

      inputs.nixd.overlays.default

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      inputs.agenix.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })

      ## Testing
      (self: super: {
        # libsForQt5 = super.libsForQt5.overrideScope (qt5self: qt5super: {
        #   sddm = qt5super.sddm.overrideAttrs (old: {
        #     patches = (old.patches or [ ]) ++ [
        #       (pkgs.fetchpatch {
        #         url =
        #           "https://github.com/sddm/sddm/commit/1a78805be83449b1b9c354157320f7730fcc9f36.diff";
        #         sha256 = "sha256-JNsVTJNZV6T+SPqPkaFf3wg8NDqXGx8NZ4qQfZWOli4=";
        #       })
        #     ];
        #   });
        # });

        tor-browser-bundle-bin = super.symlinkJoin {
          name = super.tor-browser-bundle-bin.name;
          paths = [ super.tor-browser-bundle-bin ];
          buildInputs = [ super.makeWrapper ];
          postBuild = ''
            wrapProgram "$out/bin/tor-browser" \
              --set MOZ_ENABLE_WAYLAND 1
          '';
        };

        mpv =
          super.mpv.override { scripts = with super.mpvScripts; [ mpris ]; };
        # vaapiIntel = super.vaapiIntel.override { enableHybridCodec = true; };
        deadbeef = super.deadbeef.override { wavpackSupport = true; };
        deadbeef-with-plugins = super.deadbeef-with-plugins.override {
          plugins = with super.deadbeefPlugins; [ mpris2 statusnotifier ];
        };
      })
    ];
    # Configure your nixpkgs instance
    config = {
      allowBroken = true;
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Accept the joypixels license
      joypixels.acceptLicense = true;
      allowUnsupportedSystem = true;
      permittedInsecurePackages = [ "openssl-1.1.1w" "electron-19.1.9" ];

      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      # allowUnfreePredicate = _: true;

      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "nvidia-settings"
          "nvidia-x11"
          "spotify"
          "steam"
          "steam-original"
          "steam-run"
          "vscode"
          "dubai"

          # they got fossed recently so idk
          "Anytype"
        ];
    };
  };

  nix = {
    checkConfig = true;
    checkAllErrors = true;

    # 🍑 smooth rebuilds
    # give nix-daemon the lowest priority
    # Reduce disk usage
    daemonIOSchedClass = "idle";
    # Leave nix builds as a background task
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7; # only used by "best-effort"

    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
      dates = "00:00";
    };

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
      config.nix.registry;

    optimise.automatic = true;
    package = pkgs.unstable.nix;
    settings = {
      accept-flake-config = true;
      sandbox = "relaxed";
      show-trace = true;
      auto-optimise-store = true;
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;
      keep-going = lib.mkForce true;

      experimental-features = [
        "auto-allocate-uids"
        "nix-command"
        "flakes"
        "repl-flake"
        "ca-derivations"
        "cgroups"
      ];
      # Allow to run nix
      allowed-users = [ "${username}" "wheel" ];
      builders-use-substitutes =
        true; # Avoid copying derivations unnecessary over SSH.

      trusted-users = [ "root" "${username}" ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://juca-nixfiles.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "juca-nixfiles.cachix.org-1:HN1wk6GxLI1ZPr3bN2RNa+a4jXwLGUPJG6zXKqDZ/Kc="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };
    extraOptions = ''
      log-lines = 15

      # If set to true, Nix will fall back to building from source if a binary substitute fails.
      #fallback = true

      # Free up to 4GiB whenever there is less than 2GiB left.
      min-free = ${toString (2048 * 1024 * 1024)}
      max-free = ${toString (4096 * 1024 * 1024)}
      # Free up to 4GiB whenever there is less than 512MiB left.
      #min-free = ${toString (512 * 1024 * 1024)}
      #min-free = 1073741824 # 1GiB
      #max-free = 4294967296 # 4GiB
      #builders-use-substitutes = true

      connect-timeout = 10
    '';

    # distributedBuilds = true;
  };

  #############################################
  ### Keep nixos and home-manager separated ###
  #############################################
  # User Specific home-manager Profile
  # home-manager = {
  #   useUserPackages = true;
  #   useGlobalPkgs = true;
  # };
}
