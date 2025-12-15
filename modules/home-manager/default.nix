{ inputs, lib, config, pkgs, username, stateVersion, outputs, isNixOS, osConfig ? null, isWorkstation, ... }:
let
  inherit (lib) mkDefault mkIf optional;

  isNixOS = osConfig != null;
  inherit (pkgs.stdenv) isLinux isDarwin;

  systemModules = with inputs; [
    sops-nix.homeManagerModules.sops
    nix-index-database.homeModules.nix-index
    nix-flatpak.homeManagerModules.nix-flatpak
    # chaotic.homeManagerModules.default
    nur.modules.homeManager.default
  ];
in
{

  imports = [
    ./apps
    ./disabled/catppuccin-delta-fix.nix
  ] ++
  optional isWorkstation ./desktop;

  config = {
    nixpkgs = {
      overlays = [
        # Add overlays your own flake exports (from overlays and pkgs dir):
        outputs.overlays.localPackages
        outputs.overlays.modifiedPackages
        outputs.overlays.unstable-packages
        outputs.overlays.oldstable-packages

        inputs.nixgl.overlay
        inputs.nur.overlays.default
      ];
      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
        # allowUnfreePredicate = (_: true);
        # permittedInsecurePackages = [ ];
      };
    };

    nix = let flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs; in {
      package = lib.mkIf (!isNixOS) pkgs.nixVersions.latest;
      settings = {
        experimental-features = "flakes nix-command";
        trusted-users = [ "${username}" "@wheel" ]; # root
        allowed-users = [ "${username}" "@wheel" ]; # root
        warn-dirty = false;
        allow-dirty = true;
      };
      extraOptions = ''
        # Free up to 1GiB whenever there is less than 100MiB left.
        # min-free = ${toString (100 * 1024 * 1024)}
        # max-free = ${toString (1024 * 1024 * 1024)}
        # Free up to 2GiB whenever there is less than 1GiB left.
        min-free = ${toString (1024 * 1024 * 1024)}        # 1 GiB
        max-free = ${toString (3 * 1024 * 1024 * 1024)}    # 3 GiB
      ''
      + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin
      '';

      nixPath = lib.mkIf (!isNixOS) (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
    };

    # TODO: Set your username
    home = {
      username = "${username}";
      homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
      activation = {
        diff = lib.hm.dag.entryAnywhere ''
          if [[ -n ''${oldGenPath:-} ]] && [[ -n ''${newGenPath:-} ]]; then
            ${lib.getExe config.nix.package} \
              --extra-experimental-features 'nix-command' \
              store diff-closures $oldGenPath $newGenPath || true
          fi
        '';
      };
      sessionVariables = {
        NIXPKGS_ALLOW_UNFREE = "1";
        NIXPKGS_ALLOW_INSECURE = "1";
      };
      enableNixpkgsReleaseCheck = false;
      stateVersion = stateVersion; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    };

    news.display = "silent";

    # Enable home-manager and git
    programs = {
      home-manager.enable = true;
      git.enable = true;
    };

    systemd = {
      # Nicely reload system units when changing configs
      user.startServices = mkIf isLinux "sd-switch";
    };
  };
}
