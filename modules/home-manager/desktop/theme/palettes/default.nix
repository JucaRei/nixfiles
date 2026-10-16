# Índice automático: cada `palettes/<nome>.nix` vira a paleta `<nome>`.
# Arquivos que começam com "_" são helpers e não viram paleta.
{
  lib,
  pkgs,
  accent,
}:
let
  isPalette =
    name: type: type == "regular" && lib.hasSuffix ".nix" name && !lib.hasPrefix "_" name && name != "default.nix";
in
lib.mapAttrs' (
  file: _:
  lib.nameValuePair (lib.removeSuffix ".nix" file) (
    import (./. + "/${file}") { inherit lib pkgs accent; }
  )
) (lib.filterAttrs isPalette (builtins.readDir ./.))
