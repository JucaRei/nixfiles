{ pkgs, lib, config, isLima, inputs, username, stateVersion, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) optionals;
in
{
  imports = [
    ../default.nix
  ]
  ++ optionals isDarwin [ ./darwin ]
  ++ optionals isLinux [ ./linux ];

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

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
    };

    enableNixpkgsReleaseCheck = false;
  };

  # Workaround home-manager bug with flakes
  # - https://github.com/nix-community/home-manager/issues/2033
  news.display = "silent";

  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      trusted-users = [ "${username}" ];
      allowed-users = [ "${username}" ];
    };
    extraOptions = ''
      # Free up to 1GiB whenever there is less than 100MiB left.
      # min-free = ${toString (100 * 1024 * 1024)}
      # max-free = ${toString (1024 * 1024 * 1024)}
      # Free up to 2GiB whenever there is less than 1GiB left.
      min-free = ${toString (1024 * 1024 * 1024)}        # 1 GiB
      max-free = ${toString (3 * 1024 * 1024 * 1024)}    # 3 GiB
    '' + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin
    '';
  };
  nixpkgs = {
    overlays = [
      inputs.nixgl.overlay # for non-nixos system's
    ];
    config = {
      # allowUnfreePredicate = (_: true);
      # permittedInsecurePackages = [ ];
    };
  };
}
