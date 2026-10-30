# lib/import-dir.nix — auto-descoberta e importação declarativa de diretórios de módulos.
#
# Convenção:
# - Importa subpastas contendo default.nix e arquivos .nix no mesmo nível.
# - Nomes iniciados por "_" (ex: _template, _common) são ignorados.
# - A pasta ou arquivo "disabled" é ignorado.
# - O próprio "default.nix" é ignorado para evitar recursão infinita.
{ lib }:

let
  inherit (builtins) readDir pathExists;
  inherit (lib.strings) hasPrefix hasSuffix;
  inherit (lib.attrsets) mapAttrsToList filterAttrs;

  # Verifica se um nome deve ser ignorado pela convenção
  isIgnored = name: hasPrefix "_" name || name == "disabled" || name == "default.nix";

  # Importa todos os módulos válidos de um diretório:
  # 1. Subpastas contendo default.nix
  # 2. Arquivos .nix regulares (exceto default.nix, disabled e _*)
  importDir =
    dir:
    let
      entries = readDir dir;
      validEntries = filterAttrs (
        name: type:
        !isIgnored name
        && (
          (type == "directory" && pathExists (dir + "/${name}/default.nix"))
          || (type == "regular" && hasSuffix ".nix" name)
        )
      ) entries;
    in
    mapAttrsToList (name: _: dir + "/${name}") validEntries;

  # Importa apenas subdiretórios diretos contendo default.nix
  importSubdirs =
    dir:
    let
      entries = readDir dir;
      validEntries = filterAttrs (
        name: type: !isIgnored name && type == "directory" && pathExists (dir + "/${name}/default.nix")
      ) entries;
    in
    mapAttrsToList (name: _: dir + "/${name}") validEntries;
in
{
  inherit importDir importSubdirs;
}
