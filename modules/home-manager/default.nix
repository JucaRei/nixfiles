{ config, lib, pkgs, inputs, outputs, username, osConfig ? null, isWorkstation ? null, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mapAttrsToList mkDefault mkIf;

  isNixOS = osConfig != null;
in
{
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

        linkDestopApplications = mkIf (!isNixOS && isWorkstation != null) {
          # Add Packages To System Menu by updating database
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          data = "${pkgs.desktop-file-utils}/bin/update-desktop-database";
        };
      };

      sessionVariables = mkDefault {
        NIXPKGS_ALLOW_UNFREE = "1";
        NIXPKGS_ALLOW_INSECURE = "1";
      };

      sessionPath = mkIf (!isNixOS && isWorkstation != null) [
        "$HOME/.local/bin"
      ];

      enableNixpkgsReleaseCheck = false;
    };

    targets.genericLinux.enable = mkIf (!isNixOS) true;

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
        allowed-users = [ "${username}" "@whell" ]; # root
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

        sessionVariables = {
          FLAKE = mkDefault "/home/${username}/.dotfiles/nixfiles";
        };
        # Create age keys directory for SOPS

        tmpfiles = mkIf isLinux {
          rules = [
            "d ${config.home.homeDirectory}/.config/sops/age 0755 ${username} users - -"
          ];
        };
      };
    };
  };
}
