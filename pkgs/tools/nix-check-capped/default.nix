{ writeShellScriptBin, nix-capped }:

writeShellScriptBin "nix-check-capped" ''
  exec ${nix-capped}/bin/nix-capped nix flake check --no-build "$@"
''
