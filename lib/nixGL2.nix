# lib/nixGL.nix
{ pkgs, nixGL ? pkgs.nixgl.auto.nixGLDefault }:

let
  inherit (pkgs.lib) concatStringsSep optionalString;

  # Internal helper: wraps a single binary
  wrapBinary = origBin: ''
    cat > "$out/bin/$(basename ${origBin})" <<EOF
    #!${pkgs.runtimeShell}
    exec ${nixGL}/bin/nixGL ${origBin} "\$@"
    EOF
    chmod +x "$out/bin/$(basename ${origBin})"
  '';

in
{
  /**
    Wraps a package's **binaries** with nixGL.
  */
  wrapper = pkg:
    if pkg == null || !(pkg ? outPath) then pkg else
    pkgs.buildEnv {
      name = "nixgl-bin-${pkg.name or pkg.pname or "unnamed"}";

      paths = [ pkg ];

      pathsToLink = [ "/bin" ];

      postBuild = ''
        mkdir -p $out/bin
        shopt -s nullglob
        for bin in ${pkg.out}/bin/*; do
          if [ -f "$bin" ] && [ -x "$bin" ]; then
            ${wrapBinary "$bin"}
          fi
        done
        shopt -u nullglob
      '';

      meta = pkg.meta or { };
      passthru = pkg.passthru or { };
      preferLocalBuild = true;
      allowSubstitutes = false;
    };

/**
  Wraps a package **including .desktop files** so that GUI launchers
  (menu entries, desktop icons) use the nixGL-wrapped binaries.
    
  Usage example:
  ```nix
  (import ./nixGL.nix { inherit pkgs; }).wrapDesktopFiles pkgs.firefox

**/

# { pkgs, nixGL ? pkgs.nixgl.auto.nixGLDefault }:

# {
#   # The actual wrapper function: takes a package and returns a wrapped one
#   wrapper = pkg:
#     if pkg == null then null else
#     pkg.overrideAttrs (old: {
#       name = "nixGL-${old.name or old.pname}";
#       buildCommand = ''
#         set -eo pipefail

#         ${pkgs.lib.concatStringsSep "\n" (map (outputName: ''
#           echo "Copying output ${outputName}"
#           cp -rs --no-preserve=mode "${pkg.${outputName}}" "''$${outputName}"
#         '') (old.outputs or ["out"]))}

#         rm -rf $out/bin/*
#         shopt -s nullglob
#         for file in ${pkg.out}/bin/*; do
#           echo "#!${pkgs.bash}/bin/bash" > "$out/bin/$(basename $file)"
#           echo "exec -a \"\$0\" ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL $file \"\$@\"" >> "$out/bin/$(basename $file)"
#           chmod +x "$out/bin/$(basename $file)"
#         done
#         shopt -u nullglob
#       '';
#     });
# }



# # Call once on import to load global context
# # { pkgs, config, }:
# { pkgs }:
# # Wrap a single package
# pkg:
# #if config.nixGLPrefix == "" then
# #  pkg
# #else
# # Wrap the package's binaries with nixGL, while preserving the rest of
# # the outputs and derivation attributes.
# (pkg.overrideAttrs (old: {
#   name = "nixGL-${pkg.name}";
#   buildCommand = ''
#     set -eo pipefail

#     ${
#       # Heavily inspired by https://stackoverflow.com/a/68523368/6259505
#       pkgs.lib.concatStringsSep "\n" (map (outputName: ''
#         echo "Copying output ${outputName}"
#         set -x
#         cp -rs --no-preserve=mode "${pkg.${outputName}}" "''$${outputName}"
#         set +x
#       '') (old.outputs or ["out"]))
#     }

#     rm -rf $out/bin/*
#     shopt -s nullglob # Prevent loop from running if no files
#     for file in ${pkg.out}/bin/*; do
#       echo "#!${pkgs.bash}/bin/bash" > "$out/bin/$(basename $file)"
#       echo "exec -a \"\$0\" ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL $file \"\$@\"" >> "$out/bin/$(basename $file)"
#       chmod +x "$out/bin/$(basename $file)"
#     done
#     shopt -u nullglob # Revert nullglob back to its normal default state
#   '';
# }))

