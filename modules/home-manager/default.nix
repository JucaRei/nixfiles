{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  username,
  osConfig ? null,
  isWorkstation,
  stateVersion,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib)
    mapAttrsToList
    mkDefault
    mkIf
    optionals
    ;

  isNixOS = osConfig != null;
in
{
  imports = [
    ./system
  ]
  ++ optionals (isWorkstation) [ ./desktop/environments ];
  config = {
    home = {
      inherit username;
      inherit stateVersion;

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

      sessionVariables = {
        NIXPKGS_ALLOW_UNFREE = "1";
      };
    };

    news.display = "silent";

    nixpkgs = {
      overlays = [
        inputs.nixgl.overlay
        inputs.nur.overlays.default
      ]
      ++ (builtins.attrValues outputs.overlays);

      config = {
        allowUnfree = true;
        allowInsecure = true;
      };
    };

    nix =
      let
        flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
      in
      {
        package = mkIf (!isNixOS) (mkDefault pkgs.nixVersions.latest);

        settings = {
          experimental-features = "flakes nix-command";
          trusted-users = [
            "${username}"
            "@wheel"
          ];
          warn-dirty = false;
        };

        nixPath = mkIf (!isNixOS) (mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
      };

    systemd = {
      user = {
        startServices = mkIf isLinux "sd-switch"; # Nicely reload system units when changing configs
      };
    };
  };
}
