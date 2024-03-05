{ config, lib, inputs, hostname, pkgs, platform, outputs, modulesPath, ... }:
let
  isInstall = if (builtins.substring 0 4 hostname != "iso-") then true else false;
in
{
  config = {
    nix = {
      # 🍑 smooth rebuilds
      # give nix-daemon the lowest priority
      # Reduce disk usage
      daemonIOSchedClass = "idle";
      # Leave nix builds as a background task
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedPriority = 7; # only used by "best-effort"

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 10d";
      };

      # distributedBuilds = true;

      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

      optimise.automatic = true;
      package = lib.mkIf (isInstall) pkgs.unstable.nix;
      settings = {
        sandbox = true; #"relaxed"
        # extra-sandbox-paths = [ ];
        auto-optimise-store = true;
        # experimental-features = ["nix-command" "flakes" "repl-flake"];
        experimental-features = "nix-command flakes repl-flake ca-derivations recursive-nix impure-derivations";
        # allowed-users = [ "root" "@wheel" ];
        # trusted-users = [ "root" "@wheel" ];
        # builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.

        # Avoid unwanted garbage collection when using nix-direnv
        keep-outputs = true;
        keep-derivations = true;
        # keep-going = false;
        warn-dirty = false;
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
      #min-free = ${toString (512 * 1024 * 1024)}
      #min-free = 1073741824 # 1GiB
      #max-free = 4294967296 # 4GiB
      #builders-use-substitutes = true
    };

    nixpkgs = {
      hostPlatform = lib.mkDefault "${platform}";

      overlays = [
        # Add overlays your own flake exports (from overlays and pkgs dir):
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        # Add overlays exported from other flakes:

        # inputs.nixd.overlays.default
        # inputs.agenix.overlays.default


        # workaround for: https://github.com/NixOS/nixpkgs/issues/154163
        # (_: super: {
        #   makeModulesClosure = x:
        #     super.makeModulesClosure (x // { allowMissing = true; });
        # })

        ## Testing
        # (self: super: {
        #   # libsForQt5 = super.libsForQt5.overrideScope (qt5self: qt5super: {
        #   #   sddm = qt5super.sddm.overrideAttrs (old: {
        #   #     patches = (old.patches or [ ]) ++ [
        #   #       (pkgs.fetchpatch {
        #   #         url =
        #   #           "https://github.com/sddm/sddm/commit/1a78805be83449b1b9c354157320f7730fcc9f36.diff";
        #   #         sha256 = "sha256-JNsVTJNZV6T+SPqPkaFf3wg8NDqXGx8NZ4qQfZWOli4=";
        #   #       })
        #   #     ];
        #   #   });
        #   # });

        #   tor-browser-bundle-bin = super.symlinkJoin {
        #     name = super.tor-browser-bundle-bin.name;
        #     paths = [ super.tor-browser-bundle-bin ];
        #     buildInputs = [ super.makeWrapper ];
        #     postBuild = ''
        #       wrapProgram "$out/bin/tor-browser" \
        #         --set MOZ_ENABLE_WAYLAND 1
        #     '';
        #   };

        #   mpv =
        #     super.mpv.override { scripts = with super.mpvScripts; [ mpris ]; };
        #   # vaapiIntel = super.vaapiIntel.override { enableHybridCodec = true; };
        #   deadbeef = super.deadbeef.override { wavpackSupport = true; };
        #   deadbeef-with-plugins = super.deadbeef-with-plugins.override {
        #     plugins = with super.deadbeefPlugins; [ mpris2 statusnotifier ];
        #   };
        # })
      ];

      config = {
        # allowBroken = true;
        # Disable if you don't want unfree packages
        allowUnfree = true;
        # Accept the joypixels license
        joypixels.acceptLicense = true;
        allowUnsupportedSystem = true;
        # permittedInsecurePackages = [ "openssl-1.1.1w" "electron-19.1.9" ];

        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        # allowUnfreePredicate = _: true;
        # allowUnfreePredicate = pkg:
        #   builtins.elem (lib.getName pkg) [
        #     "nvidia-settings"
        #     "nvidia-x11"
        #     "spotify"
        #     "steam"
        #     "steam-original"
        #     "steam-run"
        #     "vscode"
        #     # "dubai"

        #     # they got fossed recently so idk
        #     "Anytype"
        #   ];
      };
    };
  };
}
