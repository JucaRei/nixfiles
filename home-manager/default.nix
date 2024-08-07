{ config, desktop, inputs, lib, outputs, pkgs, stateVersion, username, hostname, isWorkstation, isLima, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
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

      # You can also split up your configuration and import pieces of it here:
      ./common.nix
    ]
    # ++ lib.optional (builtins.isPath (./. + "/users/${username}")) ./users/${username}
    ++ lib.optional (builtins.pathExists (./. + "/users/${username}")) ./users/${username}
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix;

  # catppuccin = {
  #   accent = "lavender";
  #   flavor = "frappe";
  # };

  home = {
    inherit stateVersion;
    inherit username;
    activation.report-changes = config.lib.dag.entryAnywhere ''
      if [[ -n "$oldGenPath" && -n "$newGenPath" ]]; then
        ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
      fi
    '';
    homeDirectory = if isDarwin then "/Users/${username}" else if isLima then "/home/${username}.linux" else "/home/${username}";

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      FLAKE = "/home/${username}/.dotfiles/nixfiles";
    };

    file = {
      ".hidden".text = ''snap'';
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
      outputs.overlays.previous-packages
      outputs.overlays.legacy-packages

      inputs.nixgl.overlay
      inputs.nur.overlay

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      # inputs.agenix.overlays.default

      # Or define it inline, for example:
      (_final: _prev: {
        # hi = final.hello.overrideAttrs (oldAttrs: {
        #   patches = [ ./change-hello-to-hi.patch ];
        # });

        # awesome = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-git;
      })
    ];

    # Configure your nixpkgs instance
    config = {
      # allowUnsupportedSystem = true; # Allow unsupported packages to be built
      # allowBroken = false; # Disable broken package
      permittedInsecurePackages = [
        ### Allow old broken electron
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        # "electron-21.4.0"
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

    package = pkgs.unstable.nix;

    settings =
      if isDarwin then {
        nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ];
        daemonIOLowPriority = true;
      }
      else {
        accept-flake-config = true;
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
        sandbox =
          if (isDarwin)
          then true
          else "relaxed"; #false

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
        allowed-users = [ "root" "@wheel" ];
        trusted-users = [ "root" "@wheel" ];
        connect-timeout = 5;
        http-connections = 0;

      };
    extraOptions =
      ''
        log-lines = 15

        fallback = true

        # Free up to 1GiB whenever there is less than 100MiB left.
        # min-free = ${toString (100 * 1024 * 1024)}
        # max-free = ${toString (1024 * 1024 * 1024)}
        # Free up to 2GiB whenever there is less than 1GiB left.
        min-free = ${toString (1024 * 1024 * 1024)}        # 1 GiB
        max-free = ${toString (3 * 1024 * 1024 * 1024)}    # 2 GiB
      ''
      + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin
      '';
  };

  systemd.user = {
    # Nicely reload system units when changing configs
    startServices = lib.mkIf isLinux "sd-switch";

    services.nix-index-database-sync = {
      Unit.Description = "fetch mic92/nix-index-database";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "fetch-nix-index-database";
          runtimeInputs = with pkgs; [ wget coreutils ];
          text = ''
            mkdir -p ~/.cache/nix-index
            cd ~/.cache/nix-index
            name="index-${pkgs.stdenv.system}"
            wget -N "https://github.com/Mic92/nix-index-database/releases/latest/download/$name"
            ln -sf "$name" "files"
          '';
        });
        Restart = "on-failure";
        RestartSec = "5m";
      };
    };

    timers.nix-index-database-sync = {
      Unit.Description = "Automatic github:mic92/nix-index-database fetching";
      Timer = {
        OnBootSec = "10m";
        OnUnitActiveSec = "24h";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
