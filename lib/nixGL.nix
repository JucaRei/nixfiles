# lib/nixGL.nix - Fully sandbox-safe nixGL wrapper (binary + desktop)
{ pkgs, nixGL ? pkgs.nixgl.auto.nixGLDefault }:

let
  inherit (pkgs.lib) concatStringsSep optionalString;

in
rec {
  # Binary wrapper: safe, no symlink overwrite
  wrapper = pkg:
    if pkg == null || !(pkg ? outPath) then pkg else
    pkgs.runCommandLocal "nixgl-bin-${pkg.name or pkg.pname or "unnamed"}"
      {
        inherit (pkg) meta passthru;
      } ''
            set -euo pipefail

            # Copy structure
            cp -r --no-preserve=mode "${pkg}" "$out"

            # Fresh bin dir
            rm -rf "$out/bin"
            mkdir -p "$out/bin"

            # Wrap binaries
            shopt -s nullglob
            for bin in "${pkg}"/bin/*; do
              if [ -f "$bin" ] && [ -x "$bin" ]; then
                cat > "$out/bin/$(basename "$bin")" <<EOF
      #!${pkgs.runtimeShell}
      exec ${nixGL}/bin/nixGL "$bin" "\$@"
      EOF
                chmod +x "$out/bin/$(basename "$bin")"
              fi
            done
            shopt -u nullglob
    '';

  # Desktop wrapper: patches .desktop in a writable temp dir
  wrapDesktopFiles = pkg:
    let binWrapped = wrapper pkg;
    in pkgs.runCommandLocal "nixgl-desktop-${pkg.name or pkg.pname}"
      {
        inherit (pkg) meta passthru;
      } ''
      set -euo pipefail

      cp -r --no-preserve=mode "${binWrapped}" "$out"

      # Create writable temp dir for patching
      mkdir -p temp_desktop

      shopt -s globstar nullglob
      for d in "$out"/share/applications/**/*.desktop "$out"/share/gnome/applications/**/*.desktop; do
        if [ -f "$d" ]; then
          cp "$d" temp_desktop/temp.desktop
          sed 's|^Exec=\(.*\)$|Exec=${nixGL}/bin/nixGL \1|' temp_desktop/temp.desktop > "$d"
          rm temp_desktop/temp.desktop
        fi
      done
      shopt -u globstar nullglob

      rm -rf temp_desktop
    '';
}
