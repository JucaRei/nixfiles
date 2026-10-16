# lib/nixgl — envolve binários com nixGL em distros não-NixOS.
#
# nixGLType:
#   "intel"                      -> sempre nixGLIntel (laptops Optimus em que a Intel gerencia o display)
#   "mesa"                       -> sempre nixGLMesa
#   null | "auto" | "nvidia"     -> wrapper "smart": detecta a GPU em runtime (ver wrapper.sh)
#
# Por que o "smart" não usa nixGLNvidia: ele usa o driver proprietário do próprio host
# via symlinks, então não precisa construir a versão exata do driver (quebrada no nixpkgs 26.05).
{
  pkgs,
  nixGLType ? null,
}:

let
  inherit (pkgs) lib;
  gl = pkgs.nixgl or { };

  # Caminho do executável do nixGL, ou "" se o overlay não o fornecer
  runnerFor = name: lib.optionalString (builtins.hasAttr name gl) "${gl.${name}}/bin/${name}";

  intelRunner = runnerFor "nixGLIntel";
  mesaRunner = runnerFor "nixGLMesa";

  # Trecho de shell anexado ao cabeçalho de cada binário gerado.
  # É um arquivo no store: o conteúdo só é lido em build time (sem IFD).
  fixedBody = runner: pkgs.writeText "nixgl-fixed.sh" ''exec "${runner}" "$_target_bin" "$@"'';

  smartBody = pkgs.replaceVars ./wrapper.sh {
    inherit intelRunner mesaRunner;
    nvidiaVaapiDir = "${pkgs.nvidia-vaapi-driver}/lib/dri";
  };

  body =
    if nixGLType == "intel" && intelRunner != "" then
      fixedBody intelRunner
    else if nixGLType == "mesa" && mesaRunner != "" then
      fixedBody mesaRunner
    else
      smartBody;

  # Copia o pacote e troca cada bin/* por um script que chama o original via `body`.
  wrapBinaries =
    pkg:
    pkgs.runCommandLocal "nixgl-${pkg.name or pkg.pname or "unnamed"}"
      { inherit (pkg) meta passthru; }
      ''
        set -euo pipefail
        shopt -s nullglob
        cp -r --no-preserve=mode "${pkg}" "$out"
        rm -rf "$out/bin" && mkdir -p "$out/bin"
        for bin in "${pkg}"/bin/*; do
          [ -f "$bin" ] && [ -x "$bin" ] || continue
          name="$(basename "$bin")"
          {
            printf '#!%s\n_target_bin="%s"\n' "${pkgs.runtimeShell}" "$bin"
            cat "${body}"
          } > "$out/bin/$name"
          chmod +x "$out/bin/$name"
        done
      '';

  # Mantém .override/.overrideAttrs funcionando sobre o pacote já envolvido.
  wrapper =
    pkg:
    if pkg == null || !(pkg ? outPath) then
      pkg
    else
      wrapBinaries pkg
      // lib.optionalAttrs (pkg ? override) { override = args: wrapper (pkg.override args); }
      // lib.optionalAttrs (pkg ? overrideAttrs) { overrideAttrs = f: wrapper (pkg.overrideAttrs f); };
in
{
  inherit wrapper;
}
