{ config, desktop, inputs, lib, outputs, pkgs, modulesPath, stateVersion, username, hostname, nixgl, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  isLima = builtins.substring 0 5 hostname == "lima-";
  isWorkstation = if (desktop != null) then true else false;
  isStreamstation = if (hostname == "phasma" || hostname == "vader") then true else false;
in
{
  # Only import desktop configuration if the host is desktop enabled
  # Only import user specific configuration if they have bespoke settings
  imports =
    [
      # If you want to use modules your own flake exports (from modules/home-manager):
      # outputs.homeManagerModules.example

      # Or modules exported from other flakes (such as nix-colors):
      # inputs.nix-colors.homeManagerModules.default
      # inputs.sops-nix.homeManagerModules.sops
      inputs.nix-index-database.hmModules.nix-index

      # You can also split up your configuration and import pieces of it here:
      ./_mixins
    ]
    # ++ lib.optional (builtins.isPath (./. + "/users/${username}")) ./users/${username}
    ++ lib.optional (builtins.pathExists (./. + "/users/${username}")) ./users/${username}
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix
    ++ lib.optional (isWorkstation) ./_mixins/desktop;

  home = {
    inherit username;
    inherit stateVersion;
    activation.report-changes = config.lib.dag.entryAnywhere ''
      if [[ -n "$oldGenPath" && -n "$newGenPath" ]]; then
        ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
      fi
    '';
    homeDirectory = if isDarwin then "/Users/${username}" else if isLima then "/home/${username}.linux" else "/home/${username}";

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
    };
  };

  # Workaround home-manager bug with flakes
  # - https://github.com/nix-community/home-manager/issues/2033
  news.display = "silent";

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      # inputs.nixpkgs-f2k.overlays.stdenvs
      # inputs.nixpkgs-f2k.overlays.compositors
      inputs.nixgl.overlay
      inputs.nur.overlay

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      # inputs.agenix.overlays.default

      # Or define it inline, for example:
      (final: prev: {
        # hi = final.hello.overrideAttrs (oldAttrs: {
        #   patches = [ ./change-hello-to-hi.patch ];
        # });

        # awesome = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-git;
      })
    ];

    # Configure your nixpkgs instance
    config = {
      # Allow unsupported packages to be built
      # allowUnsupportedSystem = true;
      # Disable broken package
      # allowBroken = false;
      ### Allow old broken electron
      permittedInsecurePackages = [
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        "electron-21.4.0"
        "electron-12.2.3"
        "openssl-1.1.1w"
        "electron-13.6.9"
        # "mailspring-1.11.0"
      ];
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
      # Accept the joypixels license
      joypixels.acceptLicense = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    package = pkgs.unstable.nix;
    settings =
      if isDarwin then {
        nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ];
        daemonIOLowPriority = true;
      }
      else {
        # accept-flake-config = true;
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
          # "ca-derivations"
          # "auto-allocate-uids"
          # "cgroups"
          #"configurable-impure-env"
        ];
        # auto-allocate-uids = true;
        # use-cgroups = if isLinux then true else false;
        # build-users-group = "nixbld";
        builders-use-substitutes = true;
        # sandbox =
        #   if isDarwin
        #   then true
        #   else false; #relaxed
        sandbox = true;

        # Avoid unwanted garbage collection when using nix-direnv
        # https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
        # keep-going = true;
        show-trace = true;
        keep-outputs = true;
        keep-derivations = true;
        warn-dirty = false;
        allow-dirty = true;

        # Allow to run nix
        # allowed-users = [ "nixbld" "@wheel" ];
        trusted-users = [ "root" "@wheel" ];
        connect-timeout = 5;
        http-connections = 0;

      };
    extraOptions =
      ''
        log-lines = 15

        # fallback = true

        # Free up to 1GiB whenever there is less than 100MiB left.
        # min-free = ${toString (100 * 1024 * 1024)}
        # max-free = ${toString (1024 * 1024 * 1024)}
        # Free up to 2GiB whenever there is less than 1GiB left.
        min-free = ${toString (1024 * 1024 * 1024)}        # 1 GiB
        max-free = ${toString (2 * 1024 * 1024 * 1024)}    # 2 GiB
      ''
      + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin
      '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = lib.mkIf isLinux "sd-switch";
}
