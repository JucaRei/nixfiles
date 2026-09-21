# lib/nixGL.nix - Wrapper nixGL para binários e arquivos .desktop em distros não-NixOS.
#
# nixGLType: "intel" | "nvidia" | "mesa" | "auto" | null
#   intel  → nixGLIntel   (Intel/Mesa; recomendado para laptops Optimus onde Intel gerencia o display)
#   nvidia → nixGLNvidia  (GPU NVIDIA primária)
#   mesa   → nixGLMesa    (Mesa genérico)
#   auto   → auto.nixGLDefault (detecção automática — pode falhar no nixpkgs 26.05 com NVIDIA)
#   null   → nixGLIntel como padrão seguro
#
# ATENÇÃO: auto.nixGLDefault tenta construir nixGLNvidia ao ser avaliado (mesmo com --impure).
# No nixpkgs 26.05 isso falha (API 'kernel' removida). Use nixGLType = "intel" nesses casos.
# O nixGLOverrideOverlay em lib/helpers.nix previne essa avaliação para hosts com nixGLType explícito.

{
  pkgs,
  nixGLType ? null,
}:

let
  inherit (pkgs.lib) optionalAttrs;
  gl = pkgs.nixgl or { };

  # Seleciona o pacote nixGL correto e o nome do seu binário.
  pick =
    type:
    {
      "intel"  = { pkg = gl.nixGLIntel           or null; bin = "nixGLIntel"; };
      "nvidia" = { pkg = gl.auto.nixGLNvidia      or null; bin = "nixGLNvidia"; };
      "mesa"   = { pkg = gl.nixGLMesa             or null; bin = "nixGLMesa"; };
      "auto"   = { pkg = gl.auto.nixGLDefault     or null; bin = "nixGL"; };
    }
    .${type} or { pkg = gl.nixGLIntel or null; bin = "nixGLIntel"; };

  selected = pick (if nixGLType != null then nixGLType else "intel");
  nixGL    = selected.pkg or (pkgs.writeShellScriptBin "nixGL" ''exec "$@"'');
  nixGLBin = selected.bin;

  # Cria um wrapper de binários que chama nixGL antes de cada executável.
  mkBinWrapper =
    pkg:
    pkgs.runCommandLocal "nixgl-bin-${pkg.name or pkg.pname or "unnamed"}"
      { inherit (pkg) meta passthru; }
      ''
        set -euo pipefail
        cp -r --no-preserve=mode "${pkg}" "$out"
        rm -rf "$out/bin" && mkdir -p "$out/bin"
        shopt -s nullglob
        for bin in "${pkg}"/bin/*; do
          [ -f "$bin" ] && [ -x "$bin" ] || continue
          printf '#!${pkgs.runtimeShell}\nexec ${nixGL}/bin/${nixGLBin} "%s" "$@"\n' "$bin" \
            > "$out/bin/$(basename "$bin")"
          chmod +x "$out/bin/$(basename "$bin")"
        done
        shopt -u nullglob
      '';

in
rec {
  # Envolve os binários de um pacote com nixGL (aceleração de hardware).
  wrapper =
    pkg:
    if pkg == null || !(pkg ? outPath) then
      pkg
    else
      let drv = mkBinWrapper pkg; in
      drv
      // optionalAttrs (pkg ? override)     { override     = args: wrapper (pkg.override args); }
      // optionalAttrs (pkg ? overrideAttrs) { overrideAttrs = f:   wrapper (pkg.overrideAttrs f); };

  # Envolve binários e corrige as entradas Exec= nos arquivos .desktop.
  wrapDesktopFiles =
    pkg:
    let
      wrapped = wrapper pkg;
      drv = pkgs.runCommandLocal "nixgl-desktop-${pkg.name or pkg.pname or "unnamed"}"
        { inherit (pkg) meta passthru; }
        ''
          set -euo pipefail
          cp -r --no-preserve=mode "${wrapped}" "$out"
          shopt -s globstar nullglob
          for d in "$out"/share/{,gnome/}applications/**/*.desktop; do
            [ -f "$d" ] || continue
            sed -i 's|^Exec=\(.*\)$|Exec=${nixGL}/bin/${nixGLBin} \1|' "$d"
          done
          shopt -u globstar nullglob
        '';
    in
    drv
    // optionalAttrs (pkg ? override)     { override     = args: wrapDesktopFiles (pkg.override args); }
    // optionalAttrs (pkg ? overrideAttrs) { overrideAttrs = f:   wrapDesktopFiles (pkg.overrideAttrs f); };
}
