{ config, desktop, inputs, lib, outputs, pkgs, modulesPath, stateVersion, username, hostname, nixgl, ... }:
let
  inherit (pkgs.stdenv) isDarwin;
in
{
  # Only import desktop configuration if the host is desktop enabled
  # Only import user specific configuration if they have bespoke settings
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    ./_mixins/common
    ./_mixins/dev
  ]
  # ++ lib.optional (builtins.isString desktop) ./_mixins/desktop
  # ++ lib.optional (builtins.isPath (./. + "/_mixins/users/${username}")) ./_mixins/users/${username}
  # ++ lib.optional (builtins.pathExists (./. + "/users/${username}/hosts/${hostname}.nix")) ./users/${username}/hosts/${hostname}.nix
  ++ lib.optional (builtins.isPath (./. + "/users/${username}")) ./users/${username}
  ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix
  ++ lib.optional (desktop != null) ./_mixins/desktop;

  home = lib.mkDefault {
    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    sessionPath = [ "$HOME/.local/bin" ];
    inherit stateVersion;
    inherit username;
    sessionVariables = {
      # only works for interactive shells, pam works for all kind of sessions
      NIX_PATH = (lib.concatStringsSep ":" (lib.mapAttrsToList (name: path: "${name}=${path.to.path}") config.nix.registry));
    };
    enableNixpkgsReleaseCheck = true;
    packages = [ pkgs.nixgl.auto.nixGLDefault ];
  };

  nixpkgs = {
    # You can add overlays here
    overlays = with builtins; [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.nixpkgs-f2k.overlays.stdenvs
      inputs.nixpkgs-f2k.overlays.compositors

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      inputs.agenix.overlays.default

      inputs.nixgl.overlays.default

      # Or define it inline, for example:
      (final: prev: {
        # hi = final.hello.overrideAttrs (oldAttrs: {
        #   patches = [ ./change-hello-to-hi.patch ];
        # });

        awesome = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-git;

        # Patch Google Chrome Dark Mode
        google-chrome = prev.google-chrome.overrideAttrs (old: {
          installPhase =
            old.installPhase
            + ''
              fix=" --enable-features=WebUIDarkMode --force-dark-mode"

              substituteInPlace $out/share/applications/google-chrome.desktop \
                --replace $exe "$exe$fix"
            '';
        });
      })
    ];

    # Configure your nixpkgs instance
    config = {
      # Allow unsupported packages to be built
      allowUnsupportedSystem = true;
      # Disable broken package
      allowBroken = false;
      ### Allow old broken electron
      permittedInsecurePackages = [
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        "electron-21.4.0"
        "electron-12.2.3"
        "openssl-1.1.1w"
        "electron-13.6.9"
      ];
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
      # Accept the joypixels license
      joypixels.acceptLicense = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    package = lib.mkDefault pkgs.unstable.nix;
    settings =
      if isDarwin then
        {
          nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ];
          daemonIOLowPriority = true;
        } else
        {
          accept-flake-config = true;
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
            "ca-derivations"
            "auto-allocate-uids"
            "configurable-impure-env"
          ];
          # Avoid unwanted garbage collection when using nix-direnv
          keep-outputs = true;
          keep-derivations = true;
          build-users-group = "nixbld";
          builders-use-substitutes = true;
          sandbox = if isDarwin then true else false;
          warn-dirty = false;

          # https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
          keep-going = false;
          show-trace = true;

          # Allow to run nix
          allowed-users = [ "${username}" "nixbld" "wheel" ];
          connect-timeout = 5;
          http-connections = 0;

          # substituters = [
          #   "https://nix-community.cachix.org"
          #   "https://hyprland.cachix.org"
          #   "https://juca-nixfiles.cachix.org"
          # ];
          # trusted-public-keys = [
          #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          #   "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          #   "juca-nixfiles.cachix.org-1:HN1wk6GxLI1ZPr3bN2RNa+a4jXwLGUPJG6zXKqDZ/Kc="
          # ];
        };
    extraOptions = ''
      keep-outputs          = true
      keep-derivations      = true
      connect-timeout = 5
      log-lines = 25

      fallback = true

      # Free up to 1GiB whenever there is less than 100MiB left.
      # min-free = ${toString (100 * 1024 * 1024)}
      # max-free = ${toString (1024 * 1024 * 1024)}
      # Free up to 2GiB whenever there is less than 1GiB left.
      min-free = ${toString (1024 * 1024 * 1024)}        # 1 GiB
      max-free = ${toString (2 * 1024 * 1024 * 1024)}    # 2 GiB
    '' + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
