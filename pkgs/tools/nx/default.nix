{ writeShellScriptBin }:

writeShellScriptBin "nx" (builtins.readFile ../../../scripts/nx)
