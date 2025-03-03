{ config, inputs, isLima, isWorkstation, lib, outputs, pkgs, stateVersion, username, isOtherOS, system, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) optional optionals mapAttrsToList mkForce mkIf mkOverride mkDefault mkOptionDefault;
  isNixos = builtins.hasAttr "system" config; # only present on NixOS systems
  checkVer = if isNixos then false else true;
in
{
  imports = with inputs; [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # homeManagerModules.example

    # Modules exported from other flakes:
    nur.modules.homeManager.default
    catppuccin.homeManagerModules.catppuccin
    sops-nix.homeManagerModules.sops
    nix-index-database.hmModules.nix-index
    nix-flatpak.homeManagerModules.nix-flatpak
    chaotic.homeManagerModules.default

    ./_mixins/features
    ../modules/home-manager
    ../resources/hm-configs/scripts
    ../resources/hm-configs/console
  ]
  # ++ optional (builtins.pathExists (./. + "/hosts/${hostname}")) ./hosts/${hostname}
  # ++ optional (builtins.pathExists (./. + "/users/${username}")) ./users/${username}
  ++ optional (builtins.pathExists (./. + "/hosts")) ./hosts
  ++ optional (builtins.pathExists (./. + "/users")) ./users
  ++ optional isWorkstation ../modules/home-manager/programs/graphical/desktop/environment
  ;

  # Workaround home-manager bug with flakes
  # - https://github.com/nix-community/home-manager/issues/2033
  news.display = "silent";

  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory = if isDarwin then "/Users/${username}" else if isLima then "/home/${username}.linux" else "/home/${username}";

    activation = {
      diff = lib.hm.dag.entryAnywhere ''
        if [[ -n ''${oldGenPath:-} ]] && [[ -n ''${newGenPath:-} ]]; then
          ${lib.getExe config.nix.package} \
            --extra-experimental-features 'nix-command' \
            store diff-closures $oldGenPath $newGenPath || true
        fi
      '';
    };

    packages =
      with pkgs; [
        fd # Modern Unix `find`
        netdiscover # Modern Unix `arp`
        whereis-nix # nix store path
      ]
      ++ optionals (isOtherOS) [
        pciutils # Terminal PCI info
        duf # Modern Unix `df`
        usbutils # Terminal USB info
      ];

    sessionVariables = mkOptionDefault {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      FLAKE = mkForce "/home/${username}/.dotfiles/nixfiles";
      EDITOR = "micro";

      MICRO_TRUECOLOR = "1";
      PAGER = "bat";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };

    enableNixpkgsReleaseCheck = false;
  };

  nixpkgs = {
    overlays = [
      inputs.nixgl.overlay # for non-nixos linux system's
      inputs.nur.overlays.default

      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.oldstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      # allowUnfreePredicate = (_: true);
      # permittedInsecurePackages = [ ];
    };
  };


  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      package = mkDefault pkgs.nixVersions.latest;

      settings = {
        experimental-features = "flakes nix-command";
        trusted-users = [ "root" "${username}" "@wheel" ];
        allowed-users = [ "root" "${username}" "@whell" ];
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
        # + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
        #   extra-platforms = x86_64-darwin
        # ''
      ;

      nixPath = mkIf isOtherOS (mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
    };
}
