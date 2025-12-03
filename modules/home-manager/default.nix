{ config, lib, pkgs, inputs, outputs, username, osConfig ? null, isWorkstation, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mapAttrsToList mkDefault mkIf optionals;

  isNixOS = osConfig != null;
in
{
  imports = [ ./system ]
    ++ optionals (isWorkstation) [ ./desktop/environments ];
  config = {
    home = {
      activation = {
        diff = lib.hm.dag.entryAnywhere ''
          if [[ -n ''${oldGenPath:-} ]] && [[ -n ''${newGenPath:-} ]]; then
            ${lib.getExe config.nix.package} \
              --extra-experimental-features 'nix-command' \
              store diff-closures $oldGenPath $newGenPath || true
          fi
        '';
      };

      enableNixpkgsReleaseCheck = false;
    };


    news.display = "silent";

    nixpkgs = {
      overlays = [ ] ++
        (with inputs; [
          nixgl.overlay # for non-nixos linux system's
          nur.overlays.default
        ]) ++
        (with outputs; [
          # Add overlays your own flake exports (from overlays and pkgs dir):
          overlays.localPackages
          overlays.modifiedPackages
          overlays.unstablePackages
          overlays.oldstablePackages
        ]);

      config = {
        allowUnfree = true;
        # allowUnfreePredicate = (_: true);
        # permittedInsecurePackages = [ ];
      };
    };

    nix = let flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs; in {
      package = mkIf (!isNixOS) (mkDefault pkgs.nixVersions.latest);

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

      nixPath = mkIf (!isNixOS) (mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
    };

    systemd = {
      user = {
        startServices = mkIf isLinux "sd-switch"; # Nicely reload system units when changing configs
      };
    };
  };
}
